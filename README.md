# Hestia — native iOS bootstrap

Hestia is planned as a local-first iPhone companion with an expressive
in-app character and genuine, time-bounded Live Activities. This repository
currently contains a **Task 1 project scaffold only**, not a working
Companion Mode, Dynamic Island character, artwork importer, or complete widget.

The app currently presents an original SwiftUI vector mascot, Mochi. Its
embedded WidgetKit extension supplies a temporary static bootstrap widget.
An XCTest smoke test checks that the app and the starter mascot share the
expected identifier. The first cloud macOS simulator run **passed** both
the unit smoke test and app-launch UI smoke test on October 15, 2026.

## macOS prerequisites and verification

Use a Mac with Xcode, an installed iOS 17-or-newer iPhone Simulator and
XcodeGen. These commands **cannot be run directly on this Windows PC**;
equivalent XcodeGen, build and XCTest steps were **successfully run** on
GitHub-hosted macOS in the first workflow:

    xcodegen generate
    xcodebuild -list -project Hestia.xcodeproj
    xcodebuild -project Hestia.xcodeproj -scheme Hestia -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
    bash scripts/test-ios.sh -only-testing:HestiaTests/ProjectSmokeTests test

### Cloud Mac builds from Windows

The workflow at `.github/workflows/ios-ci.yml` uses a GitHub-hosted
`macos-15` runner to install XcodeGen if necessary, generate the Xcode
project, compile the unsigned app and embedded extension for iOS Simulator,
and run both XCTest smoke suites. It records toolchain versions and
uploads logs plus an XCTest result bundle.

After pushing to the private repository, use GitHub **Actions** >
**Hestia iOS Simulator** > **Run workflow**; pushes to the `main`
branch also trigger the checks. Hosted macOS execution consumes Actions
minutes for a private repository. These checks need no Apple signing
credentials or provisioning profiles. **Initial cloud-native build and
both smoke-test suites passed**; this does not validate future
Companion Mode, ActivityKit or physical iPhone behavior.

**Private repository:** https://github.com/Aieda1l/Hestia

The first GitHub-hosted macOS run **38815590398**, October 15, 2026,
completed **successfully**: project generation, unsigned iOS simulator
app/extension build, unit smoke, UI launch smoke and result upload.
Logs: https://github.com/Aieda1l/Hestia/actions/runs/38815590398
No signed iPhone installation package is provided at this stage.

The user's **iPhone 16 Pro** supports Dynamic Island. Installing a beta
there requires an Apple-signed device build (or TestFlight once the app
and signing/distribution arrangements are ready), not an unsigned
simulator build. Hestia's ActivityKit character and Companion Mode are
still planned features, not implemented in this scaffold. Do not commit
certificates, provisioning profiles, API keys or other secrets.

The test helper discovers an available iPhone Simulator using xcrun and
fails with a BLOCKED message if the generated project, required tools or
simulator are absent. The generated Hestia scheme includes both unit and
UI test targets; the UI suite currently has only an app-launch smoke test.
Tests for the companion journey belong to a later approved task.

For TDD, the plan calls for demonstrating a RED smoke test before adding
StarterCompanion and then GREEN afterward. The initial RED failure
was **not observed** because source was first drafted on Windows,
but the completed scaffold's real cloud-hosted GREEN XCTest **passed**.
Future changes should use cloud CI to observe RED/GREEN when practical.

## Project structure and signing

The XcodeGen specification declares the Hestia app, HestiaWidgets app
extension, HestiaTests unit tests and HestiaUITests app-launch smoke tests.
App/ and Widget/ compile Shared/ separately, so the vector mascot can be
shown on both surfaces. Only the app and widget extension have entry
points; each target defines its own @main.

XcodeGen writes App/Info.plist and Widget/Info.plist when generating the
project. The app requests the NSSupportsLiveActivities Info.plist setting
for future ActivityKit work; no Live Activity currently starts or appears.

The following names are placeholders for local scaffolding and do not
belong to any verified development team:

    com.example.Hestia
    com.example.Hestia.widgets
    com.example.Hestia.tests
    com.example.Hestia.uitests
    group.com.example.Hestia

Before any signed-device attempt, use team-owned bundle identifiers and
an App Group identifier available to both the app and extension. Update
the project.yml identifiers and both entitlement files consistently,
regenerate the project, check signing and inspect the embedded extension.
No signing or physical iPhone tests have occurred.

## Known verification limits

The development workspace is on Windows, without detected Xcode, Swift
or XcodeGen commands. Project generation, Swift compilation, test-target
loading, extension embedding, Info.plist generation, and entitlement
provisioning are **not verified in this environment**. The initial Mac
generation/build/smoke-test gate must pass before later implementation
tasks proceed. Dynamic Island eligibility, Live Activity permissions,
system animation, dismissal, and App Review compliance require additional
implementation and actual device testing.

Approved design:
docs/superpowers/specs/2026-10-15-island-first-companion-design.md

Execution boundary:
Task 1 only of docs/superpowers/plans/2026-10-15-island-companion-core.md
