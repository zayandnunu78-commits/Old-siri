//
//  ContentView.swift
//  Classic Assistant
//

import SwiftUI

struct ContentView: View {
    @StateObject private var settings = AppSettings.shared
    @StateObject private var voice = VoiceManager()
    @StateObject private var appState = AppState.shared

    var body: some View {
        AssistantView(settings: settings, voice: voice, appState: appState)
    }
}

#Preview {
    ContentView()
}
