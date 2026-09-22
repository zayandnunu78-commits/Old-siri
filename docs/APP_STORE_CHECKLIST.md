# App Store submission checklist

This list is a starting point, not a guarantee of approval — always read
the current **App Store Review Guidelines** at
`developer.apple.com/app-store/review/guidelines` before submitting,
since Apple updates them regularly.

## Naming, icon, and trademark — the biggest risk for this project

Because the whole premise of this app is "inspired by the history of
Siri," this is the area most likely to cause a rejection or a trademark
dispute if handled carelessly:

- [ ] **App name does not contain "Siri"** or any other Apple trademark, in the app itself, the App Store listing title/subtitle, or the icon.
- [ ] **App icon is wholly original** — not a recolored or redrawn copy of any Siri icon from any era.
- [ ] Marketing copy and screenshots describe the app as *"inspired by"* or *"a tribute to the evolution of"* voice assistant design, and make clear it is an **independent, unofficial** project — not affiliated with or endorsed by Apple.
- [ ] No Apple screenshots, promotional renders, or product photography anywhere in the listing.
- [ ] Consider a short in-app "About" disclaimer (a draft already lives in `SettingsView.swift`) reiterating independence — this also helps a human reviewer quickly understand the app's intent.

Apple's Guideline 4.1 (Copycats) and general trademark policy are both
relevant here: review apps that could be mistaken for, or that trade on
the reputation of, an existing Apple product. Leaning into "an original
assistant with a nostalgic, era-inspired visual theme" rather than "a
Siri replica" is both the honest description of what this project is and
the one most likely to be reviewed favorably.

## Privacy

- [ ] **App Privacy details** in App Store Connect: declare that the app collects/processes audio (microphone) and speech/transcribed text, used for App Functionality, not linked to identity if you don't attach it to an account, and not used for tracking (adjust to match what you actually implement — the shipped code keeps everything on-device and in memory only).
- [ ] A **privacy policy URL** is required even for a simple app — a short static page describing that audio is processed for speech recognition and never leaves the device except through Apple's own Speech framework, and that no conversation history is uploaded anywhere, is enough for an app this size.
- [ ] Since `Speech` framework requests can use Apple's servers for recognition (unless you set `requiresOnDeviceRecognition = true`), be accurate in the privacy policy about that, or set that flag if you want a stronger on-device-only claim (note: on-device recognition supports fewer languages/features).

## Functionality & content

- [ ] Every button does something or fails gracefully — this project's error states (`AssistantState.error`) all offer Retry and Type Instead so nothing dead-ends.
- [ ] Test with microphone and speech recognition **denied** to confirm the app explains the situation instead of silently failing.
- [ ] Test with **no network connection** — on-device dictation may still work; server-based recognition will not, so confirm the network error state reads correctly.
- [ ] All 14 eras render without clipped text or overlapping elements on the smallest supported screen size.

## Metadata

- [ ] Age rating questionnaire completed (a voice assistant with no user-generated content or web access typically rates very low, but answer honestly for your final feature set).
- [ ] Export compliance: if you haven't added any custom encryption beyond what iOS/HTTPS already provides, you can typically answer "No" / rely on the standard exemption — confirm against the current questionnaire wording at submission time.
- [ ] Screenshots captured per required device size, showing a few different eras so the App Store listing itself communicates the "pick your era" concept.
- [ ] Support URL and marketing URL set.

## Before you tap Submit

- [ ] A reviewer note in App Store Connect (same short paragraph suggested in `TESTFLIGHT_GUIDE.md`) explaining the app's independent, original nature up front.
- [ ] Demo account note: not applicable (no login), but say so explicitly so the reviewer isn't left guessing.
