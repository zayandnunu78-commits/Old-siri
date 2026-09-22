//
//  SettingsView.swift
//  Classic Assistant
//

import SwiftUI
import Speech
import AVFAudio

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @ObservedObject var voice: VoiceManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Assistant") {
                    Toggle("Voice responses", isOn: $settings.voiceResponsesEnabled)
                        .onChange(of: settings.voiceResponsesEnabled) { voice.voiceResponsesEnabled = $0 }
                    Toggle("Assistant animation", isOn: $settings.animationEnabled)
                    NavigationLink {
                        EraPickerView(settings: settings)
                    } label: {
                        HStack {
                            Text("Era")
                            Spacer()
                            Text(settings.era.label).foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Microphone") {
                    LabeledContent("Microphone access", value: micStatusText)
                    LabeledContent("Speech recognition", value: speechStatusText)
                    Button("Request access") {
                        Task { _ = await voice.requestPermissions() }
                    }
                    Text("If access was previously denied, open the Settings app to change it: Settings ▸ Classic Assistant.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button("Clear conversation", role: .destructive) {
                        NotificationCenter.default.post(name: .classicAssistantClearConversation, object: nil)
                    }
                }

                Section("About") {
                    Text("Classic Assistant is an original, independent voice assistant inspired by the general look and feel of assistant interfaces across many years of iOS — not a copy of any one of them. No Apple artwork, icons, or sounds are used anywhere in this app.")
                        .font(.footnote)
                    ForEach(CommandProcessor().allExamples, id: \.self) { example in
                        Text("\u{201C}\(example)\u{201D}")
                            .font(.footnote)
                    }
                    LabeledContent("Version", value: "1.0")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var micStatusText: String {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted: return "Allowed"
        case .denied: return "Denied"
        default: return "Not asked yet"
        }
    }
    private var speechStatusText: String {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized: return "Allowed"
        case .denied, .restricted: return "Denied"
        default: return "Not asked yet"
        }
    }
}

extension Notification.Name {
    static let classicAssistantClearConversation = Notification.Name("classicAssistantClearConversation")
}
