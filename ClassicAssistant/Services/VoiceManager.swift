//
//  VoiceManager.swift
//  Classic Assistant
//
//  Wraps Speech (speech-to-text) and AVSpeechSynthesizer (text-to-speech).
//  Publishes a single AssistantState so the UI stays a thin, voice-first
//  layer over this state machine. Every wait has a timeout so the UI can
//  never get stuck on a loading state.
//
//  NOTE: This file has been written carefully against the public Speech /
//  AVFoundation APIs but has not been compiled — this project ships as
//  source only, since building and signing an iOS app requires Xcode on
//  macOS, which this environment does not have. Build it in Xcode and fix
//  up any small API drift for the SDK version you target (see README).
//

import Foundation
import Speech
import AVFoundation
import Combine

@MainActor
final class VoiceManager: NSObject, ObservableObject {

    @Published private(set) var state: AssistantState = .idle
    @Published private(set) var transcript: String = ""
    @Published var voiceResponsesEnabled: Bool = true

    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let synthesizer = AVSpeechSynthesizer()

    private var watchdog: Task<Void, Never>?
    private var sessionToken = UUID()

    var onFinalTranscript: ((String) -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    // MARK: - Permissions

    /// Requests microphone + speech recognition permission. Call this once,
    /// e.g. from Settings or the first time the mic button is tapped.
    func requestPermissions() async -> Bool {
        let speechStatus = await withCheckedContinuation { (cont: CheckedContinuation<SFSpeechRecognizerAuthorizationStatus, Never>) in
            SFSpeechRecognizer.requestAuthorization { status in
                cont.resume(returning: status)
            }
        }
        guard speechStatus == .authorized else { return false }

        let micGranted = await withCheckedContinuation { (cont: CheckedContinuation<Bool, Never>) in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                cont.resume(returning: granted)
            }
        }
        return micGranted
    }

    // MARK: - Listening

    func startListening() {
        let mySession = UUID()
        sessionToken = mySession
        transcript = ""
        state = .starting

        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            fail(.speechRecognitionUnavailable)
            return
        }

        Task {
            let micStatus = AVAudioSession.sharedInstance().recordPermission
            let speechStatus = SFSpeechRecognizer.authorizationStatus()

            if speechStatus == .notDetermined || micStatus == .undetermined {
                let granted = await requestPermissions()
                guard mySession == sessionToken else { return }
                if !granted {
                    fail(.microphoneDenied)
                    return
                }
            } else if speechStatus == .denied || speechStatus == .restricted {
                fail(.speechRecognitionDenied)
                return
            } else if micStatus == .denied {
                fail(.microphoneDenied)
                return
            }

            beginAudioSession(session: mySession)
        }

        armWatchdog(seconds: 12) { [weak self] in
            guard let self, self.sessionToken == mySession, self.state == .starting else { return }
            self.fail(.timeout)
        }
    }

    private func beginAudioSession(session: UUID) {
        guard session == sessionToken else { return }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            fail(.microphoneUnavailable)
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if #available(iOS 13, *) { request.requiresOnDeviceRecognition = false }
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            fail(.microphoneUnavailable)
            return
        }

        state = .listening
        armWatchdog(seconds: 20) { [weak self] in
            guard let self, self.sessionToken == session else { return }
            self.stopListening()
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self, self.sessionToken == session else { return }
            Task { @MainActor in
                if let result {
                    self.transcript = result.bestTranscription.formattedString
                    if result.isFinal {
                        self.finishListening(session: session)
                    }
                }
                if let error {
                    let nsError = error as NSError
                    // Code 216/203-ish "no speech" cases surface as cancellation once we
                    // stop the audio engine ourselves; only treat *unsolicited* errors
                    // as failures.
                    if self.state == .listening || self.state == .starting {
                        if nsError.domain == "kAFAssistantErrorDomain" {
                            self.fail(.noSpeechDetected)
                        } else {
                            self.fail(.network)
                        }
                    }
                }
            }
        }
    }

    /// User tapped the mic again, or the max-listen watchdog fired: stop
    /// capturing audio and let the recognizer deliver its final result.
    func stopListening() {
        guard state == .listening else { return }
        state = .thinking
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        armWatchdog(seconds: 8) { [weak self] in
            guard let self, self.state == .thinking else { return }
            self.fail(.noSpeechDetected)
        }
    }

    private func finishListening(session: UUID) {
        guard session == sessionToken else { return }
        let text = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        if text.isEmpty {
            fail(.noSpeechDetected)
        } else {
            state = .thinking
            onFinalTranscript?(text)
        }
    }

    // MARK: - Speaking

    func speak(_ text: String) {
        guard voiceResponsesEnabled else {
            state = .responding
            // No speech will fire a "did finish" delegate callback, so
            // return to idle on our own after giving the person time to read.
            let mySession = sessionToken
            let readTime = min(1.6 + Double(text.count) * 0.035, 6.0)
            armWatchdog(seconds: readTime) { [weak self] in
                guard let self, self.sessionToken == mySession, self.state == .responding else { return }
                self.reset()
            }
            return
        }
        let mySession = sessionToken
        state = .preparing
        armWatchdog(seconds: 4) { [weak self] in
            guard let self, self.sessionToken == mySession, self.state == .preparing else { return }
            self.fail(.textToSpeechUnavailable)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            fail(.textToSpeechUnavailable)
            return
        }
        synthesizer.speak(utterance)
    }

    func skipSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        reset()
    }

    // MARK: - Lifecycle

    func reset() {
        sessionToken = UUID()
        watchdog?.cancel()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        if synthesizer.isSpeaking { synthesizer.stopSpeaking(at: .immediate) }
        transcript = ""
        state = .idle
    }

    private func fail(_ error: AssistantError) {
        watchdog?.cancel()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        state = .error(error)
    }

    private func armWatchdog(seconds: Double, _ action: @escaping () -> Void) {
        watchdog?.cancel()
        watchdog = Task {
            try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await MainActor.run { action() }
        }
    }
}

extension VoiceManager: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in self.state = .responding }
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in self.reset() }
    }
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in self.reset() }
    }
}
