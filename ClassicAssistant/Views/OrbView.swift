//
//  OrbView.swift
//  Classic Assistant
//
//  Renders the assistant's central visual for every era whose visual
//  family isn't `.edgeGlow`. The same three states (idle/listening/
//  responding) are expressed differently per family so each era still
//  feels distinct, while sharing one codepath.
//

import SwiftUI

struct OrbView: View {
    let theme: EraTheme
    let state: AssistantState
    let animationsEnabled: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse = false
    @State private var rotate = false

    private var motionAllowed: Bool { animationsEnabled && !reduceMotion }

    var body: some View {
        Group {
            switch theme.era.visualFamily {
            case .skeuomorphic: skeuomorphicOrb
            case .flatClassic, .flatRefined: fullScreenWave
            case .floatingOrb: compactOrb
            case .edgeGlow: EmptyView() // handled by EdgeGlowView instead
            }
        }
        .onAppear { startAnimating() }
        .onChange(of: animationsEnabled) { _ in startAnimating() }
        .onChange(of: reduceMotion) { _ in startAnimating() }
    }

    private var energy: CGFloat {
        switch state {
        case .listening: return 1.15
        case .responding: return 1.1
        case .thinking, .preparing, .starting: return 1.0
        default: return 0.92
        }
    }

    // MARK: iOS 5–6: glossy, textured sphere with a small internal equalizer
    private var skeuomorphicOrb: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [theme.accentColors.first ?? .blue, theme.accentColors.last ?? .blue, .black.opacity(0.6)],
                                      center: UnitPoint(x: 0.35, y: 0.28), startRadius: 4, endRadius: theme.orbDiameter))
                .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 1))
                .overlay(
                    Ellipse()
                        .fill(LinearGradient(colors: [.white.opacity(0.65), .white.opacity(0)], startPoint: .top, endPoint: .bottom))
                        .frame(width: theme.orbDiameter * 0.7, height: theme.orbDiameter * 0.32)
                        .offset(y: -theme.orbDiameter * 0.24)
                )
                .shadow(color: (theme.accentColors.first ?? .blue).opacity(0.6), radius: 26)
                .scaleEffect(pulse ? energy : energy * 0.96)
            equalizerBars
        }
        .frame(width: theme.orbDiameter, height: theme.orbDiameter)
    }

    private var equalizerBars: some View {
        HStack(spacing: 4) {
            ForEach(0..<5, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 4, height: barHeight(i))
            }
        }
    }
    private func barHeight(_ i: Int) -> CGFloat {
        guard motionAllowed, state == .listening || state == .responding else { return 8 }
        let phase = pulse ? 1.0 : 0.3
        let base: [CGFloat] = [10, 20, 28, 18, 12]
        return base[i % base.count] * (0.5 + 0.5 * CGFloat(phase))
    }

    // MARK: iOS 7–12: full-screen colourful wave, flat and thin
    private var fullScreenWave: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    WaveShape(phase: rotate ? .pi * 2 : 0, amplitude: waveAmplitude(i), frequency: 1.4 + Double(i) * 0.3)
                        .stroke(
                            LinearGradient(colors: theme.accentColors, startPoint: .leading, endPoint: .trailing),
                            style: StrokeStyle(lineWidth: theme.era.visualFamily == .flatRefined ? 5 : 3, lineCap: .round)
                        )
                        .opacity(0.9 - Double(i) * 0.25)
                        .frame(height: geo.size.height * 0.5)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
            }
        }
        .frame(height: 160)
    }
    private func waveAmplitude(_ i: Int) -> CGFloat {
        guard motionAllowed else { return 6 }
        switch state {
        case .listening: return 26 - CGFloat(i) * 6
        case .responding: return 22 - CGFloat(i) * 5
        case .thinking, .preparing, .starting: return 10
        default: return 6
        }
    }

    // MARK: iOS 13–17: small, compact glowing orb (not full-screen)
    private var compactOrb: some View {
        Circle()
            .fill(AngularGradient(colors: theme.accentColors + [theme.accentColors[0]], center: .center))
            .frame(width: theme.orbDiameter, height: theme.orbDiameter)
            .blur(radius: 0.5)
            .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))
            .shadow(color: (theme.accentColors.first ?? .blue).opacity(0.8), radius: pulse ? 22 : 12)
            .scaleEffect(pulse ? energy : energy * 0.94)
            .rotationEffect(.degrees(rotate ? 360 : 0))
    }

    private func startAnimating() {
        guard motionAllowed else { pulse = false; rotate = false; return }
        withAnimation(.easeInOut(duration: theme.pulseDuration).repeatForever(autoreverses: true)) {
            pulse = true
        }
        withAnimation(.linear(duration: theme.pulseDuration * 6).repeatForever(autoreverses: false)) {
            rotate = true
        }
    }
}

/// A simple animated sine-wave path used by the flat, full-screen eras.
private struct WaveShape: Shape {
    var phase: CGFloat
    var amplitude: CGFloat
    var frequency: Double

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = rect.height / 2
        path.move(to: CGPoint(x: 0, y: midY))
        let step = 2.0
        var x: CGFloat = 0
        while x <= rect.width {
            let relativeX = x / rect.width
            let angle = relativeX * .pi * 2 * CGFloat(frequency) + phase
            let y = midY + sin(angle) * amplitude
            path.addLine(to: CGPoint(x: x, y: y))
            x += step
        }
        return path
    }
}
