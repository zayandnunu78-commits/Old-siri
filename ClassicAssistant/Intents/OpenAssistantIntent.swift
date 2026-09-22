//
//  OpenAssistantIntent.swift
//  Classic Assistant
//
//  Uses the App Intents framework (iOS 16+) so people can build a Shortcut
//  — or invoke this app via "Hey Siri, [phrase]" — that opens Classic
//  Assistant and starts listening immediately. This does NOT use SiriKit's
//  older Intents/Intents UI extensions and does not require the
//  com.apple.developer.siri entitlement: App Shortcuts register themselves
//  automatically. See README.md → "Shortcuts & Siri integration".
//

import AppIntents

struct OpenAssistantIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Classic Assistant"
    static var description = IntentDescription("Opens Classic Assistant and starts listening.")

    // Bring the app to the foreground so the person sees the mic listening.
    static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        AppState.shared.pendingStartListening = true
        return .result()
    }
}

/// Registers the phrases that show up automatically in the Shortcuts app
/// and can be spoken to Siri once the app has been launched at least once.
struct ClassicAssistantShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenAssistantIntent(),
            phrases: [
                "Open \(.applicationName)",
                "Start \(.applicationName)",
                "Ask \(.applicationName) something"
            ],
            shortTitle: "Open Assistant",
            systemImageName: "mic.circle.fill"
        )
    }
}
