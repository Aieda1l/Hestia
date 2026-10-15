# Hestia — planned verification gates

Updated 2026-10-15. **Initial native app and extension compilation + unit/UI smoke tests PASSED on a GitHub-hosted Mac (run 38815590398), not locally on Windows.** Full feature tests, signed device validation and App Review checks remain unrun. References: [approved spec](superpowers/specs/2026-10-15-island-first-companion-design.md), [observed gap analysis](GAP_ANALYSIS.md).

## Evidence ladder

1. **Source baseline:** original SwiftUI starter was absent. Approved minimal Task 1 scaffold now has `project.yml`, `App/`, `Widget/`, `Shared/`, `HestiaTests/`, `HestiaUITests/`, `scripts/` and `README.md`. A private Git repository was initialized and pushed to `Aieda1l/Hestia`.
2. **Mac project generation/compilation:** `xcodegen generate`; `xcodebuild -list -project Hestia.xcodeproj`; `xcodebuild -project Hestia.xcodeproj -scheme Hestia -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build`. These commands were executed **successfully on GitHub-hosted macOS**, not directly on Windows.
3. **Simulator XCTest:** list available simulator IDs using `xcrun simctl list -j devices available` and use a discovered destination for targeted tests plus UI smoke. Do not invent IDs or passing logs.
4. **Signed iPhones:** supply owned bundle IDs and matching App Group entitlements in the app and widget extension. Validate on at least one Dynamic Island iPhone and one iPhone without Island on a current supported iOS.
5. **Release:** separately review App Review rules, license evidence, privacy disclosure, access needs, signing, accessibility and energy usage.

## Acceptance cases

| Area | Unit / integration cases | Native/system acceptance |
|---|---|---|
| Companion Mode | Default starter, ON/OFF persisted across store instances and relaunch, App Group failure | First use within about 60 seconds, labels and no account |
| Genuine finite task | Allowed window ≤8h, one UUID, repeat Start, saved task/duration, stop, end failure | Real task and current Island/Lock Screen |
| Reconciliation | Crash between Activity.request and ID save, stale vs ended/dismissed/missing, deadline while suspended | Force-quit/relaunch/dismiss/expiry, timer at zero without false claim |
| ActivityKit | Disabled authorization, failed request, authorized start/update/end; no background update loop | Compact/minimal/expanded/Lock Screen; preemption and Always-On |
| One-tap renewal | Last task/duration, new UUID, new request, permission-failure recovery | One tap **in Hestia** starts a new legitimate session |
| Image import | Valid PNG/JPEG/GIF; original GIF frames, still poster; corrupt/large inputs; Photos/Files access | Animation only in foreground app, stable still in Island |
| Shared art lifetime | Per-session immutable poster, file retention through Lock Screen dismissal | Switching pet during session doesn't alter old art |
| Widget | Selected still, failure fallback and reload request | Actual small/medium add, tint, delayed refresh; no GIF loops |
| Inclusive/private UX | Motion opt-out, VoiceOver, large text, contrast, offline errors | Lock Screen personal-art warning and signed device review |

## Hard stops

- **Task 1 status on 2026-10-15:** static Python/PyYAML `project.yml` parse/schema assertions, parsed matching plist entitlements, and Git Bash shell syntax passed; actual `bash scripts/test-ios.sh -only-testing:HestiaTests/ProjectSmokeTests test` returned **BLOCKED (exit 2, missing xcrun)**. This is **not** a Swift compile, XCTests, or RED/GREEN evidence.
- **Updated Task 1 native status:** GitHub Actions run `38815590398` ran XcodeGen, unsigned Xcode build and XCTest smoke tests successfully on macOS. This is real native GREEN evidence for the *completed scaffold*; a deliberate preceding RED failure was not observed. All Companion Mode/Live Activity feature tests remain future work.

- Without a Mac/Xcode, mark native build/tests **blocked**, never passing.
- Without a signed Dynamic Island iPhone, do not claim Island animation/visibility, live asset sharing or App Store readiness.
- With a recovered different starter or configuration, stop and revise the plan before overwriting.
- If any proposed animation technique fails publicly supported API or App Review fit, retain static pose; do not add a background timer loophole.
