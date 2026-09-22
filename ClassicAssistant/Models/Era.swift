//
//  Era.swift
//  Classic Assistant
//
//  Defines the 14 selectable design eras (iOS 5 through iOS 18). Each era
//  carries only *original* metadata describing the general design language
//  of that period (colors, shapes, motion) — no Apple assets, wordmarks,
//  or sounds are referenced or bundled anywhere in this project.
//

import Foundation

/// The broad visual family an era belongs to. Several consecutive eras
/// share a family because Apple's own design language changed in a small
/// number of major waves, not once per OS version. Each era still gets
/// its own accent colors and label so the picker has 14 distinct entries.
enum VisualFamily: String, Codable {
    case skeuomorphic      // glossy, textured, richly shaded (era 1)
    case flatClassic       // flat colour, thin type, full-screen wave (era 2)
    case flatRefined       // flat, slightly bouncier / more saturated wave (era 3)
    case floatingOrb       // dark mode, compact non-full-screen orb (era 4)
    case edgeGlow          // animated light border around the whole screen (era 5)
}

enum SiriEra: Int, CaseIterable, Identifiable, Codable {
    case ios5 = 5, ios6, ios7, ios8, ios9, ios10, ios11, ios12,
         ios13, ios14, ios15, ios16, ios17, ios18

    var id: Int { rawValue }

    var label: String { "iOS \(rawValue)" }

    /// Roughly when this design language shipped. Shown as flavor text only.
    var yearLabel: String {
        switch self {
        case .ios5: return "2011"
        case .ios6: return "2012"
        case .ios7: return "2013"
        case .ios8: return "2014"
        case .ios9: return "2015"
        case .ios10: return "2016"
        case .ios11: return "2017"
        case .ios12: return "2018"
        case .ios13: return "2019"
        case .ios14: return "2020"
        case .ios15: return "2021"
        case .ios16: return "2022"
        case .ios17: return "2023"
        case .ios18: return "2024"
        }
    }

    var tagline: String {
        switch self {
        case .ios5:  return "Textured glass, the first assistant screen."
        case .ios6:  return "Polished chrome and gloss."
        case .ios7:  return "Flat colour arrives. Thin type, bold gradients."
        case .ios8:  return "Flat, refined. Softer motion."
        case .ios9:  return "Flat, proactive, a touch more colour."
        case .ios10: return "Wider gradients, richer wave motion."
        case .ios11: return "A bigger, bouncier wave takes over the screen."
        case .ios12: return "Same language, tightened up."
        case .ios13: return "Dark mode. The assistant becomes a compact glow."
        case .ios14: return "Compact and quick, tucked into the corner."
        case .ios15: return "Same compact glow, softer gradient."
        case .ios16: return "Refined compact glow."
        case .ios17: return "Typed or spoken, same glowing indicator."
        case .ios18: return "The whole screen edge lights up instead."
        }
    }

    var visualFamily: VisualFamily {
        switch self {
        case .ios5, .ios6: return .skeuomorphic
        case .ios7, .ios8, .ios9, .ios10: return .flatClassic
        case .ios11, .ios12: return .flatRefined
        case .ios13, .ios14, .ios15, .ios16, .ios17: return .floatingOrb
        case .ios18: return .edgeGlow
        }
    }

    /// Whether this era's assistant screen takes over the full display
    /// (early eras) or shows as a small compact indicator (iOS 13+).
    var isFullScreenTakeover: Bool {
        switch visualFamily {
        case .skeuomorphic, .flatClassic, .flatRefined: return true
        case .floatingOrb, .edgeGlow: return false
        }
    }

    static var defaultEra: SiriEra { .ios7 }
}
