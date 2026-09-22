//
//  EdgeGlowView.swift
//  Classic Assistant
//
//  An original take on "the assistant becomes the whole screen border"
//  instead of a central orb. Draws an animated, colourful glow that traces
//  the inside edge of the screen. No Apple artwork is used or referenced.
//

import SwiftUI

struct EdgeGlowView: View {
    let theme: EraTheme
    let state: AssistantState
    let animationsEnabled: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animate = false

    var body: some View {
        GeometryReader { geo in
            RoundedRectangle(cornerRadius: theme.cornerRadius + 18, style: .continuous)
                .strokeBorder(
                    AngularGradient(colors: theme.accentColors + [theme.accentColors[0]],
                                     center: .center,
                                     angle: .degrees(animate ? 360 : 0)),
                    lineWidth: lineWidth
                )
                .blur(radius: 3)
                .opacity(opacity)
                .frame(width: geo.size.width, height: geo.size.height)
                .allowsHitTesting(false)
        }
        .ignoresSafeArea()
        .onAppear { start() }
        .onChange(of: animationsEnabled) { _ in start() }
        .onChange(of: reduceMotion) { _ in start() }
    }

    private var lineWidth: CGFloat {
        switch state {
        case .listening: return 14
        case .responding: return 12
        case .thinking, .preparing, .starting: return 8
        default: return 5
        }
    }
    private var opacity: Double {
        switch state {
        case .listening, .responding: return 1
        case .thinking, .preparing, .starting: return 0.75
        case .error: return 0.25
        default: return 0.55
        }
    }

    private func start() {
        guard animationsEnabled && !reduceMotion else { animate = false; return }
        withAnimation(.linear(duration: theme.pulseDuration * 3).repeatForever(autoreverses: false)) {
            animate = true
        }
    }
}
