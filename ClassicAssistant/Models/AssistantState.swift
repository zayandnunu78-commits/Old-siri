//
//  AssistantState.swift
//  Classic Assistant
//

import Foundation

enum AssistantState: Equatable {
    case idle
    case starting        // "Starting microphone…"
    case listening       // "Listening…"
    case thinking        // "Thinking…"
    case preparing       // "Preparing response…"
    case responding
    case error(AssistantError)

    var statusText: String {
        switch self {
        case .idle: return "I'm ready when you are."
        case .starting: return "Starting microphone…"
        case .listening: return "Listening…"
        case .thinking: return "Thinking…"
        case .preparing: return "Preparing response…"
        case .responding: return ""
        case .error: return ""
        }
    }

    var isBusy: Bool {
        switch self {
        case .idle, .error: return false
        default: return true
        }
    }
}

enum AssistantError: Equatable {
    case microphoneDenied
    case speechRecognitionDenied
    case microphoneUnavailable
    case speechRecognitionUnavailable
    case recognitionFailed
    case noSpeechDetected
    case textToSpeechUnavailable
    case network
    case timeout
    case unexpected

    var title: String {
        switch self {
        case .microphoneDenied: return "Microphone access is off"
        case .speechRecognitionDenied: return "Speech recognition access is off"
        case .microphoneUnavailable: return "No microphone found"
        case .speechRecognitionUnavailable: return "Speech recognition isn't available"
        case .recognitionFailed: return "I couldn't catch that"
        case .noSpeechDetected: return "I didn't hear anything."
        case .textToSpeechUnavailable: return "I couldn't speak that response"
        case .network: return "I couldn't reach speech recognition"
        case .timeout: return "The microphone took too long to start"
        case .unexpected: return "Something went wrong"
        }
    }

    var message: String {
        switch self {
        case .microphoneDenied:
            return "Allow microphone access for Classic Assistant in Settings, then try again."
        case .speechRecognitionDenied:
            return "Allow Speech Recognition access for Classic Assistant in Settings, then try again."
        case .microphoneUnavailable:
            return "Check that a microphone is available and not in use by another app."
        case .speechRecognitionUnavailable:
            return "Speech recognition isn't supported on this device or language. You can type instead."
        case .recognitionFailed:
            return "Something went wrong while listening. Try again, or type your message."
        case .noSpeechDetected:
            return "Tap the microphone and speak, or type a message."
        case .textToSpeechUnavailable:
            return "The response is on screen. You can try speaking it again."
        case .network:
            return "Check your internet connection and try again."
        case .timeout:
            return "Try again, or type your message instead."
        case .unexpected:
            return "An unexpected error stopped that request. Try again."
        }
    }
}
