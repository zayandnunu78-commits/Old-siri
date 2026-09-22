//
//  AssistantView.swift
//  Classic Assistant
//
//  The whole app is really this one screen: a status line, a central
//  visualization, and a microphone button. Deliberately not a chat log —
//  only the most recent exchange is shown, so the experience stays
//  voice-first rather than becoming a chatbot transcript.
//

import SwiftUI

struct AssistantView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var voice: VoiceManager
    @ObservedObject var appState: AppState

    @State private var showSettings = false
    @State private var lastUserText: String = ""
    @State private var lastResponseText: String = ""
    @State private var typedText: String = ""
    @State private var showTypeField = false

    private let commands = CommandProcessor()

    private var theme: EraTheme { EraTheme(era: settings.era) }

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            if theme.era.visualFamily == .edgeGlow {
                EdgeGlowView(theme: theme, state: voice.state, animationsEnabled: settings.animationEnabled)
            }

            VStack(spacing: 0) {
                header

                Spacer(minLength: 0)

                exchangeArea
                    .padding(.horizontal, 28)

                Spacer(minLength: 12)

                if theme.era.visualFamily != .edgeGlow {
                    OrbView(theme: theme, state: voice.state, animationsEnabled: settings.animationEnabled)
                        .padding(.bottom, 8)
                }

                statusText
                    .padding(.bottom, 18)

                if showTypeField {
                    typeBar
                }

                micButton
                    .padding(.bottom, 28)
            }

            if case .error(let err) = voice.state {
                errorPanel(err)
            }
        }
        .onAppear(perform: configureCommands)
        .onChange(of: appState.pendingStartListening) { pending in
            guard pending else { return }
            appState.pendingStartListening = false
            beginListening()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(settings: settings, voice: voice)
        }
        .onReceive(NotificationCenter.default.publisher(for: .classicAssistantClearConversation)) { _ in
            lastUserText = ""
            lastResponseText = ""
        }
        .animation(.easeInOut(duration: 0.2), value: voice.state)
        .preferredColorScheme(.dark)
    }

    // MARK: Header

    private var header: some View {
        HStack {
            Text(settings.era.label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(theme.secondaryTextColor)
            Spacer()
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundStyle(theme.textColor)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Settings")
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: Exchange (minimal, not a chat log)

    private var exchangeArea: some View {
        VStack(spacing: 10) {
            if !lastUserText.isEmpty {
                Text(lastUserText)
                    .font(.body.weight(.medium))
                    .foregroundStyle(theme.secondaryTextColor)
                    .multilineTextAlignment(.center)
            }
            if !lastResponseText.isEmpty {
                Text(lastResponseText)
                    .font(.title3.weight(theme.titleFontWeight))
                    .foregroundStyle(theme.textColor)
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var statusText: some View {
        Group {
            if case .error = voice.state {
                EmptyView()
            } else {
                Text(voice.state.statusText)
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(theme.textColor)
                    .accessibilityLabel(voice.state.statusText)
            }
        }
    }

    // MARK: Mic button

    private var micButton: some View {
        Button(action: micTapped) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: theme.accentColors, startPoint: .top, endPoint: .bottom))
                    .frame(width: 78, height: 78)
                    .shadow(color: (theme.accentColors.first ?? .blue).opacity(0.7), radius: voice.state == .listening ? 20 : 10)
                Image(systemName: micSymbolName)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .accessibilityLabel(micAccessibilityLabel)
        .frame(minWidth: 44, minHeight: 44)
    }

    private var micSymbolName: String {
        switch voice.state {
        case .listening: return "mic.fill"
        case .error: return "arrow.clockwise"
        default: return "mic.fill"
        }
    }
    private var micAccessibilityLabel: String {
        switch voice.state {
        case .idle: return "Start listening"
        case .listening: return "Stop listening"
        case .error: return "Try listening again"
        default: return "Cancel"
        }
    }

    // MARK: Type bar (fallback when speech recognition is unavailable)

    private var typeBar: some View {
        HStack {
            TextField("Type a message", text: $typedText)
                .textFieldStyle(.roundedBorder)
                .onSubmit(submitTyped)
            Button("Send", action: submitTyped)
                .disabled(typedText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    // MARK: Error panel

    private func errorPanel(_ error: AssistantError) -> some View {
        VStack(spacing: 14) {
            Text(error.title)
                .font(.headline)
                .multilineTextAlignment(.center)
            Text(error.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            HStack(spacing: 12) {
                Button("Retry") { voice.reset(); beginListening() }
                    .buttonStyle(.borderedProminent)
                Button("Type instead") { voice.reset(); showTypeField = true }
                    .buttonStyle(.bordered)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: theme.cornerRadius))
        .padding(.horizontal, 32)
        .accessibilityElement(children: .combine)
    }

    // MARK: Actions

    private func micTapped() {
        switch voice.state {
        case .idle, .error:
            beginListening()
        case .listening:
            voice.stopListening()
        default:
            voice.reset()
        }
    }

    private func beginListening() {
        showTypeField = false
        voice.startListening()
    }

    private func submitTyped() {
        let text = typedText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        typedText = ""
        handle(text)
    }

    private func configureCommands() {
        commands.onOpenSettings = { showSettings = true }
        commands.onGoHome = { showSettings = false }
        commands.onClearConversation = {
            lastUserText = ""
            lastResponseText = ""
        }
        commands.isSettingsOpen = { showSettings }
        voice.voiceResponsesEnabled = settings.voiceResponsesEnabled
        voice.onFinalTranscript = { text in
            handle(text)
        }
    }

    private func handle(_ text: String) {
        lastUserText = text
        let result = commands.run(text)
        lastResponseText = result.text
        result.effect?()
        voice.voiceResponsesEnabled = settings.voiceResponsesEnabled
        voice.speak(result.text)
    }
}
