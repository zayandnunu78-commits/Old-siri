# Using itch.io as the project's hub (correctly)

itch.io is a great **project page, devlog, and press-kit host** for this
app. It is **not** a way to let people install the iOS app directly —
that's an iOS platform restriction, not an itch.io limitation, and this
project should not try to work around it.

## What itch.io can host for this project

- A project page with the app's story, screenshots of a few different eras, and a devlog as you build.
- Downloadable **non-executable** material: press kit images, the original artwork/palette references for each era, design docs, maybe a short demo video or GIF of the era picker.
- A link out to your **public TestFlight beta link** once you have one (see `TESTFLIGHT_GUIDE.md`).
- A link to the **App Store listing** once it ships.

## What itch.io cannot do here

- **Host an installable `.ipa` that people tap to install**, the way it hosts a `.exe` or an Android `.apk`. iOS does not let a random `.ipa` downloaded from a browser install itself — it has no equivalent of "allow installs from unknown sources." A person's only legitimate ways to get a signed build onto their iPhone are:
  1. **TestFlight** (what this project is set up for), or
  2. **The App Store**, or
  3. Their own **Apple Developer account** building and installing it themselves via Xcode, or
  4. In the **EU only**, an Apple-authorized **alternative app marketplace** under the Digital Markets Act — a real option as of recent iOS versions, but a whole separate distribution setup (its own agreement with Apple, notarization, region restrictions) that's out of scope for this project and only relevant to EU users. Don't plan on this as your primary channel.
- Do **not** point people at "sideloading via AltStore" or similar unofficial installer tools as a workaround for this project — beyond being outside this project's brief, third-party unofficial installers are exactly the kind of code-signing bypass this project is intentionally avoiding.

## Suggested page structure

1. **About** — what the app is, the "inspired by, not a copy of" framing, screenshots per era.
2. **Try the beta** — your public TestFlight link, with a one-line note that testers need the free TestFlight app from the App Store.
3. **Devlog** — progress updates as you build out each era.
4. **Coming to the App Store** — link once live.
