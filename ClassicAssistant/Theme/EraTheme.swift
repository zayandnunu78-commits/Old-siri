//
//  EraTheme.swift
//  Classic Assistant
//
//  Turns a SiriEra into the concrete, original-artwork visual tokens the
//  rest of the app renders with. Nothing here references any Apple asset,
//  font, icon, or sound file — every gradient and shape is defined in code.
//

import SwiftUI

struct EraTheme {
    let era: SiriEra

    // MARK: Palette
    /// The 2-4 colors that make up this era's signature gradient.
    var accentColors: [Color] {
        switch era {
        case .ios5:  return [Color(hex: 0x4A9BFF), Color(hex: 0x1D4FA8)]
        case .ios6:  return [Color(hex: 0x6FB6FF), Color(hex: 0x2C63C9)]
        case .ios7:  return [Color(hex: 0x33C7FF), Color(hex: 0x6E5CFF), Color(hex: 0xFF4FB8)]
        case .ios8:  return [Color(hex: 0x35D0FF), Color(hex: 0x5A6BFF), Color(hex: 0xFF5FA8)]
        case .ios9:  return [Color(hex: 0x2FE0C8), Color(hex: 0x4C7CFF), Color(hex: 0xFF6FB0)]
        case .ios10: return [Color(hex: 0x28E0D0), Color(hex: 0x6A5CFF), Color(hex: 0xFF5FA0)]
        case .ios11: return [Color(hex: 0x21D6FF), Color(hex: 0x8A5CFF), Color(hex: 0xFF4FD0)]
        case .ios12: return [Color(hex: 0x21D6FF), Color(hex: 0x8A5CFF), Color(hex: 0xFF4FD0)]
        case .ios13: return [Color(hex: 0x3AA0FF), Color(hex: 0x8A5CFF), Color(hex: 0xFF4FD0)]
        case .ios14: return [Color(hex: 0x3AA0FF), Color(hex: 0x8A5CFF), Color(hex: 0xFF4FD0)]
        case .ios15: return [Color(hex: 0x46E6FF), Color(hex: 0x8A5CFF), Color(hex: 0xFF66C4)]
        case .ios16: return [Color(hex: 0x46E6FF), Color(hex: 0x8A5CFF), Color(hex: 0xFF66C4)]
        case .ios17: return [Color(hex: 0x53E4FF), Color(hex: 0x9A6CFF), Color(hex: 0xFF66C4)]
        case .ios18: return [Color(hex: 0xFFB86C), Color(hex: 0xFF66C4), Color(hex: 0x9A6CFF), Color(hex: 0x53E4FF)]
        }
    }

    var background: LinearGradient {
        switch era.visualFamily {
        case .skeuomorphic:
            return LinearGradient(colors: [Color(hex: 0x2B3040), Color(hex: 0x1A1D28)],
                                   startPoint: .top, endPoint: .bottom)
        case .flatClassic, .flatRefined:
            return LinearGradient(colors: [Color(hex: 0x0B0E1A), Color(hex: 0x05070E)],
                                   startPoint: .top, endPoint: .bottom)
        case .floatingOrb, .edgeGlow:
            return LinearGradient(colors: [Color.black, Color(hex: 0x0A0A0F)],
                                   startPoint: .top, endPoint: .bottom)
        }
    }

    var textColor: Color { .white }
    var secondaryTextColor: Color { Color.white.opacity(0.62) }

    // MARK: Shape language
    var cornerRadius: CGFloat {
        switch era.visualFamily {
        case .skeuomorphic: return 14
        case .flatClassic: return 20
        case .flatRefined: return 22
        case .floatingOrb: return 26
        case .edgeGlow: return 28
        }
    }

    var isGlossy: Bool { era.visualFamily == .skeuomorphic }
    var usesThinType: Bool {
        switch era.visualFamily {
        case .skeuomorphic: return false
        default: return true
        }
    }

    var fontWeight: Font.Weight { isGlossy ? .bold : .regular }
    var titleFontWeight: Font.Weight { isGlossy ? .bold : .semibold }

    // MARK: Motion
    /// How energetic the idle/listening animation should feel. Kept subtle
    /// throughout so the app stays comfortable and battery-friendly.
    var pulseDuration: Double {
        switch era.visualFamily {
        case .skeuomorphic: return 2.6
        case .flatClassic: return 2.0
        case .flatRefined: return 1.6
        case .floatingOrb: return 1.4
        case .edgeGlow: return 3.2
        }
    }

    /// Diameter of the primary orb/wave element, before the full-screen
    /// wave eras stretch it edge to edge.
    var orbDiameter: CGFloat {
        switch era.visualFamily {
        case .skeuomorphic: return 128
        case .flatClassic, .flatRefined: return 220
        case .floatingOrb: return 64
        case .edgeGlow: return 0 // n/a — edge glow has no central orb
        }
    }
}

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
