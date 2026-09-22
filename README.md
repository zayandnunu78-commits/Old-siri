# Classic Assistant — iOS source project

An original, independent voice assistant whose entire look changes across
**14 selectable eras** inspired by the *general design language* of iOS 5
through iOS 18 (skeuomorphic glass → flat color → dark, compact glow →
whole-screen edge light). No Apple assets, icons, sounds, or interface
files are used or bundled anywhere — every gradient, shape, and animation
is original code (see `Theme/EraTheme.swift`).

## What's in this delivery, and what isn't

This is a complete **XcodeGen-backed iOS project**: `project.yml` defines the
application target, generated Info.plist, iOS 16 deployment target, exact
bundle identifier, and `ClassicAssistant` scheme; `codemagic.yaml` defines
the Codemagic build and App Store signing workflow. Every Swift file uses
public `SwiftUI` / `Speech` / `AVFoundation` / `AppIntents` APIs. Building,
running, signing, and testing an iOS app still requires Xcode on a Mac — a
toolchain that does not exist in this Linux sandbox — so **compilation and
signing have not been verified here**. Use `docs/BUILD_AND_SIGNING.md` for
the exact Mac and Codemagic commands.

## Project layout

```
ClassicAssistant/
  README.md                          (this file)
  docs/
    TESTFLIGHT_GUIDE.md
    APP_STORE_CHECKLIST.md
    ITCHIO_DISTRIBUTION.md
  ClassicAssistant/
    ClassicAssistantApp.swift        @main entry point
    ContentView.swift                wires settings + voice manager together
    Models/
      Era.swift                      the 14 eras + which "visual family" each belongs to
      AssistantState.swift           idle/starting/listening/thinking/preparing/responding/error
    Theme/
      EraTheme.swift                 turns an Era into colors, gradients, shapes, motion — ALL original
    Views/
      AssistantView.swift            the whole app: status text, orb, mic button, minimal exchange
      OrbView.swift                  central visualization for 13 of the 14 eras
      EdgeGlowView.swift             screen-edge glow visualization for the iOS-18-inspired era
      EraPickerView.swift            grid to pick an era
      SettingsView.swift             voice/animation toggles, permissions, about
    Services/
      VoiceManager.swift             Speech (STT) + AVSpeechSynthesizer (TTS), with timeouts
      CommandProcessor.swift         the expandable command registry (see below)
      AppSettings.swift              persisted settings + shared AppState for Shortcuts
    Intents/
      OpenAssistantIntent.swift      App Intents / Shortcuts integration
    Supporting/
      InfoPlist-Additions.xml        the Info.plist keys this app needs
```

## Create or build the Xcode project

From the repository root, run `xcodegen generate --spec project.yml`, or let
Codemagic run the same command. This creates `ClassicAssistant.xcodeproj`
with the `ClassicAssistant` scheme; no manual target recreation or plist
copying is required. On a Mac, open that project in Xcode, choose a team under
**Signing & Capabilities**, and build on a simulator or a real iPhone. For
TestFlight/App Store distribution, follow `docs/BUILD_AND_SIGNING.md`.

No extra **capability** or entitlement is needed for the Shortcuts integration — see below.

## Shortcuts & Siri integration

This uses the modern **App Intents** framework (`Intents/OpenAssistantIntent.swift`), not the older SiriKit Intents extension:

- `OpenAssistantIntent` opens the app and flips `AppState.shared.pendingStartListening`, which `AssistantView` observes to start listening immediately.
- `ClassicAssistantShortcuts` (an `AppShortcutsProvider`) registers phrases like "Open Classic Assistant" automatically — the person doesn't need to build anything for the *basic* Shortcut to exist; it shows up in the Shortcuts app and can be triggered by name via Siri once the app has been launched once.
- Because this uses App Shortcuts rather than a custom SiriKit intents extension, **you do not need the `com.apple.developer.siri` entitlement or a "Siri" capability toggle.** If you later add custom SiriKit intents (e.g. a donated `INIntent`), that's when the entitlement and an Intents extension target become necessary — out of scope here.
- Requires iOS 16+ on the device; this is why the deployment target above is set to 16.0.

## Command system

`CommandProcessor.swift` is a flat list of `Command` values (id, example
phrases, a `match` closure, a `run` closure). Adding a new voice command
is one entry in `commands`, nothing else changes. The starter set mirrors
a typical "Version 1" assistant: hello/hi, time, date, who are you, tell
me a joke, open settings, go home, clear conversation — with `"I don't
know how to do that yet."` for anything unmatched.

## Accessibility

- All interactive controls (mic, settings gear, era cards) carry explicit `accessibilityLabel`s that describe the current state (e.g. "Stop listening" vs "Start listening").
- Text uses SwiftUI's system fonts (`.body`, `.title3`, etc.), so it follows the person's Dynamic Type size automatically.
- `OrbView` and `EdgeGlowView` both read `@Environment(\.accessibilityReduceMotion)` and fall back to a static, low-motion presentation when Reduce Motion is on, in addition to the in-app animation toggle.
- Status changes are plain `Text` views, which VoiceOver reads as they update — no color-only signaling.

Because none of this has run in a real accessibility inspector, re-check
with Xcode's Accessibility Inspector and a VoiceOver pass once it's
building, and adjust contrast/labels as needed per era (the very bright,
saturated gradients in the later eras are the ones most worth
double-checking against WCAG contrast for the text sitting on top of them).

## Distribution

See `docs/TESTFLIGHT_GUIDE.md`, `docs/APP_STORE_CHECKLIST.md`, and
`docs/ITCHIO_DISTRIBUTION.md` — in short: itch.io can host your project
page, devlog, screenshots, and a link to your public TestFlight beta, but
**cannot** be used to sideload an installable `.ipa` the way it could for
a desktop game. Legitimate iOS distribution is TestFlight (beta) and the
App Store (release) — that's what this project is structured for.
