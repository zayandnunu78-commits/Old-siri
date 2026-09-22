# TestFlight beta guide

TestFlight is the only legitimate way to get a pre-release build of an
iOS app onto other people's phones (see `ITCHIO_DISTRIBUTION.md` for why
itch.io alone can't do this). Facts below were confirmed current as of
this project's delivery; double-check `developer.apple.com` if it's been
a while, since Apple does change these numbers occasionally.

## Prerequisites

- A paid Apple Developer Program membership (individual or organization).
- An App ID / bundle identifier registered in App Store Connect, matching your Xcode project's bundle identifier.
- A build **archived and uploaded** from Xcode (Product ▸ Archive ▸ Distribute App ▸ TestFlight & App Store).

## Internal vs. external testing

| | Internal testers | External testers |
|---|---|---|
| Who | People on your App Store Connect team | Anyone, via email or a public link |
| Limit | Up to 100 people, 30 devices each | Up to 10,000 people **per app** |
| Review | None — available as soon as the build finishes processing | Apple's **Beta App Review** must approve the *first* build of each new version (usually a day or two) |

- Builds expire after **90 days**; upload a fresh build before then to keep testing going.
- A **public link** is the easiest way to run an open beta — anyone with the link can join up to the 10,000-tester cap, without you collecting emails one by one.

## Suggested flow for this project

1. Start with **internal testing** while you're iterating on the 14 eras and voice flow — instant, no review.
2. Once it feels solid, submit a build for **external testing** with a short note for the reviewer explaining what the app is: *"Classic Assistant is an original voice-assistant app whose visual theme is inspired by, but does not copy, historical Apple interface eras. It contains no Apple artwork, wordmarks, or sounds."* This kind of context helps reviewers evaluate the app on its own, rather than flagging it for a manual trademark check.
3. Generate a **public TestFlight link** and put that link (not an `.ipa`) on your itch.io page.
4. Prune inactive testers periodically if you're running a large open beta and approach the 10,000 cap (App Store Connect ▸ TestFlight ▸ your external group ▸ sort by sessions/status).

## Common rejection reasons worth avoiding up front

- Crashing on launch on a fresh device (test on a real iPhone, not just Simulator).
- Missing or vague `NSMicrophoneUsageDescription` / `NSSpeechRecognitionUsageDescription` strings — Apple checks these are specific about *why* the app needs the permission (the ones in `Supporting/InfoPlist-Additions.xml` already are).
- Placeholder/lorem-ipsum content still present.
