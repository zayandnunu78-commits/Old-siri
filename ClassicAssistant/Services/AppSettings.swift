//
//  AppSettings.swift
//  Classic Assistant
//

import Foundation
import Combine

@MainActor
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var era: SiriEra {
        didSet { UserDefaults.standard.set(era.rawValue, forKey: Keys.era) }
    }
    @Published var voiceResponsesEnabled: Bool {
        didSet { UserDefaults.standard.set(voiceResponsesEnabled, forKey: Keys.voice) }
    }
    @Published var animationEnabled: Bool {
        didSet { UserDefaults.standard.set(animationEnabled, forKey: Keys.animation) }
    }

    private enum Keys {
        static let era = "settings.era"
        static let voice = "settings.voiceResponses"
        static let animation = "settings.animation"
    }

    private init() {
        let stored = UserDefaults.standard.integer(forKey: Keys.era)
        era = SiriEra(rawValue: stored) ?? .defaultEra
        voiceResponsesEnabled = UserDefaults.standard.object(forKey: Keys.voice) as? Bool ?? true
        animationEnabled = UserDefaults.standard.object(forKey: Keys.animation) as? Bool ?? true
    }
}

/// Shared, app-wide signal used by the App Intents / Shortcuts integration
/// (see Intents/OpenAssistantIntent.swift) to tell the already-running or
/// freshly-launched UI "start listening now" without any private API.
@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()
    @Published var pendingStartListening = false
    private init() {}
}
