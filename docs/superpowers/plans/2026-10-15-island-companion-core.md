# Hestia Island Companion Core Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Status:** **APPROVED FOR EXECUTION** by user on 2026-10-15. **Task 1 source scaffold prepared and independently reviewed; Mac/Xcode RED/GREEN gate BLOCKED** on this Windows host. Task 2+ and all art/widget tasks remain unstarted until the native gate passes. No generated project, Swift compilation, signed device test or Git commit exists.

**Goal:** Produce a usable native iPhone character companion with persistent Companion Mode, authentic time-bounded Dynamic Island/Lock Screen sessions, truthful fallbacks and a one-tap user-initiated restart with the previous task/duration.

**Architecture:** An app-owned local settings/session store feeds a thin ActivityKit adapter and a WidgetKit Live Activity extension. Pure session rules are tested independently of ActivityKit; app presentation is SwiftUI. A simple original SwiftUI vector mascot is the first character, so no proprietary or unlicensed art is needed for this core vertical slice.

**Tech Stack:** Swift 5.9+ language setting, SwiftUI, ActivityKit, WidgetKit, XCTest and XcodeGen for iOS 17+. Swift target is a **proposed baseline**, not verified against an existing app or SDK. No backend, animation framework or third-party runtime dependencies.

**Spec:** `docs/superpowers/specs/2026-10-15-island-first-companion-design.md` (written design approved). The follow-on art/widget plan is `docs/superpowers/plans/2026-10-15-companion-art-and-widget.md`.

## Global Constraints

- **No app code yet exists:** `/projects/Hestia` on Windows contains docs only and is not a Git repository; find/reconcile old source before creating a new scaffold. **Approval of this plan would authorize the minimal replacement scaffold only if the old starter remains absent.**
- Selected companion + Companion Mode stay ON until the user stops; this is **stored state, not background execution**.
- An Island Live Activity needs a genuine reading/studying/creating task, a start and an end; maximum eight hours active, **not guaranteed displayed**. Default proposed window six hours; shorter real windows allowed. No perpetual renewal.
- **One tap in Hestia** can request a new legitimate bounded Live Activity after expiry using the previous task/duration. No automatic restart or repeated setup. One task session at a time.
- Island and Lock Screen are system controlled; use native countdown dates and **stable character still**. A brief visual update only when an actual meaningful ActivityKit state change can execute; no GIF loops or timer-driven background redraws.
- Support denied Live Activities, app relaunch, stale/dismissed state, activity request/end failure, no Island hardware, Reduce Motion, VoiceOver, large text, Lock Screen art disclosure and offline use.
- No team account or valid App Group ID is known. `com.example.Hestia`, `com.example.Hestia.widgets` and `group.com.example.Hestia` are **local scaffold-only names**, **not claimable production identifiers**. Before signed-device checks replace all consistently with developer-owned identifiers and matching provisioning entitlements; do not guess the user's team ID.
- There is no Mac/Xcode/toolchain today; `xcodegen` / `xcodebuild` instructions below are **proposed and unexecuted**. A Mac with an eligible iPhone is required to claim this increment passes.
- Preserve existing user files, never initialize Git or copy/rewrite an unexpectedly restored starter without explicit review.
- **Execution stop:** Task 1's first real Mac `xcodegen`, `xcodebuild` and smoke test gates must pass before proceeding to Tasks 2–5. This Windows environment cannot meet that condition. Do not continue creating large uncompiled Swift stacks and call them verified.

## Review Focus

1. **ActivityKit authorization disabled after Companion Mode starts:** maintain local ON flag, show an in-app task state and actionable Settings guidance; never claim Island success (Task 4 tests).
2. **Crash after Activity.request but before saving its returned ID:** recover exactly one matching activity using a stable UUID in ActivityAttributes, not a second request (Tasks 2–3 tests).
3. **App suspended at 6-hour deadline:** native countdown may hit zero but must not falsely claim ContentState changed or the Live Activity ended; reconcile when the app next runs (Tasks 2, 4).
4. **Two rapid Start/Restart taps or an end failure:** never spawn duplicate logical sessions; report pending system end and retry when able (Tasks 2–4).
5. **No Island hardware or iOS preemption:** keep useful in-app and Lock Screen surfaces; the app never equates an active Activity with guaranteed Island visibility (Tasks 3–5).

## File map — proposed only

| File | Responsibility |
|---|---|
| `project.yml` | XcodeGen app/WidgetKit/test target definition, deployment and embedding |
| `App/HestiaApp.swift` | SwiftUI entry point and dependency wiring |
| `App/CompanionHomeView.swift` | Adopt/start/stop, truthful status, task picker, restart/end, preview and accessibility |
| `Shared/StarterMascotView.swift` | Original simple native vector mascot compiled into app and extension |
| `App/CompanionPreferencesStore.swift` | Persist selected starter, mode flag, last task/duration and motion preference |
| `Shared/HestiaModels.swift` | Codable companion/task/session identifiers and shared static ActivityKit attributes |
| `App/SessionWindowEngine.swift` | Pure single-active-window rules, expiry and reconciliation decisions |
| `App/SessionWindowStore.swift` | Durable one-window UUID/start/deadline/phase/activityID record with crash-safe write order |
| `App/LiveActivityClient.swift` | Protocol, native ActivityKit client and session coordinator with injected fake support |
| `Widget/HestiaWidgets.swift` | Live Activity Lock Screen + Island compact/minimal/expanded views; second plan adds Home Screen widget |
| `App/Hestia.entitlements`; `Widget/HestiaWidgets.entitlements` | Identical local App Group capability for app/extension |
| `HestiaTests/*Tests.swift` | Unit tests of storage, session engine and injected activity adapter |
| `HestiaUITests/CompanionFlowUITests.swift` | One-minute first-use, tap restart and permission fallback smoke |
| `HestiaUITests/ProjectUITestSmoke.swift` | Minimal initial UI-test source so the UI-test target has a real compile input before Task 5 |
| `scripts/test-ios.sh` | Discovers an installed iPhone simulator and runs the exact requested XCTest selector; fails explicitly if none |
| `README.md` | Mac setup, signing identifiers, verification status and known limits |

The previously described source files are absent. If restored, **map the existing modules first** and adjust this file map before executing any code task.

## Task 1: Establish the verifiable native baseline

**Files:** Create `project.yml`, `App/HestiaApp.swift`, `Shared/StarterMascotView.swift`, `Widget/HestiaWidgets.swift` (temporary basic static widget to keep the extension target compiling), `App/Hestia.entitlements`, `Widget/HestiaWidgets.entitlements`, `scripts/test-ios.sh`, `HestiaTests/ProjectSmokeTests.swift`, `HestiaUITests/ProjectUITestSmoke.swift`, `README.md`. No old user source may be overwritten.

**Interfaces:** Produces the `Hestia` app module and `HestiaWidgets` extension (embedded), with `HestiaTests` and `HestiaUITests` targets. App Group scaffold key `group.com.example.Hestia`.

- [ ] **Step 1: Re-inspect before creating anything.** Run in the Hestia folder: `git status --short --branch` (absence expected currently), `rg --files -g '*.swift' -g project.yml -g '*.xcodeproj/**'`. If the old starter appears, STOP and revise paths/commit strategy, instead of scaffolding over it.
- [ ] **Step 2: Write a first failing smoke test.** `HestiaTests/ProjectSmokeTests.swift`:

```swift
import XCTest
@testable import Hestia

final class ProjectSmokeTests: XCTestCase {
    func testAppCompilesWithOriginalMascotIdentifier() {
        XCTAssertEqual(StarterCompanion.id, "starter-orb")
    }
}
```

- [ ] **Step 3: Create the minimum project/test target wiring first, without implementing `StarterCompanion`.** Set up `project.yml`, a bare `App/HestiaApp.swift`, two entitlements and an extension entrypoint that compiles independently using a temporary local widget. First `HestiaTests` compilation must fail on the missing `StarterCompanion` asserted in Step 2; only then add the following implementation to `Shared/StarterMascotView.swift`:

```swift
import SwiftUI

enum StarterCompanion {
    static let id = "starter-orb"
    static let defaultName = "Mochi"
}

struct StarterMascotView: View {
    var body: some View {
        ZStack {
            Circle().fill(.purple.opacity(0.3))
            HStack(spacing: 12) {
                Circle().fill(.primary).frame(width: 8, height: 8)
                Circle().fill(.primary).frame(width: 8, height: 8)
            }
        }
        .frame(width: 64, height: 64)
        .accessibilityLabel("Mochi, Hestia starter companion")
    }
}
```

  Add `@main HestiaApp: App` with `WindowGroup { StarterMascotView() }`. Use XcodeGen target names exactly `Hestia`, `HestiaWidgets`, `HestiaTests`, `HestiaUITests`; app sources `App/` + `Shared/`, extension sources `Widget/` + `Shared/`. The complete initial `project.yml` shape is:

```yaml
name: Hestia
options:
  deploymentTarget:
    iOS: "17.0"
settings:
  base:
    SWIFT_VERSION: "5.9"
targets:
  Hestia:
    type: application
    platform: iOS
    sources: [App, Shared]
    info:
      path: App/Info.plist
      properties:
        CFBundleDisplayName: Hestia
        NSSupportsLiveActivities: true
        CFBundleURLTypes:
          - CFBundleURLSchemes: [hestia]
    entitlements:
      path: App/Hestia.entitlements
      properties:
        com.apple.security.application-groups: [group.com.example.Hestia]
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.example.Hestia
    dependencies:
      - target: HestiaWidgets
        embed: true
  HestiaWidgets:
    type: app-extension
    platform: iOS
    sources: [Widget, Shared]
    info:
      path: Widget/Info.plist
      properties:
        NSExtension:
          NSExtensionPointIdentifier: com.apple.widgetkit-extension
    entitlements:
      path: Widget/HestiaWidgets.entitlements
      properties:
        com.apple.security.application-groups: [group.com.example.Hestia]
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.example.Hestia.widgets
        APPLICATION_EXTENSION_API_ONLY: YES
  HestiaTests:
    type: bundle.unit-test
    platform: iOS
    sources: [HestiaTests]
    dependencies: [Hestia]
    settings:
      base:
        TEST_HOST: "$(BUILT_PRODUCTS_DIR)/Hestia.app/Hestia"
        BUNDLE_LOADER: "$(TEST_HOST)"
  HestiaUITests:
    type: bundle.ui-testing
    platform: iOS
    sources: [HestiaUITests]
    dependencies: [Hestia]
    settings:
      base:
        TEST_TARGET_NAME: Hestia
schemes:
  Hestia:
    build:
      targets:
        Hestia: all
        HestiaWidgets: all
    test:
      targets: [HestiaTests, HestiaUITests]
```

  XcodeGen's spec allows generated Info.plist, entitlements, target dependencies and scheme test targets: https://github.com/yonaskolb/XcodeGen/blob/master/Docs/ProjectSpec.md . In `Widget/HestiaWidgets.swift`, define a compiling `@main WidgetBundle` with one `StaticConfiguration(kind: "HestiaBootstrap", provider: BootstrapProvider())` rendering `Text("Mochi")`; `BootstrapProvider` conforms to `TimelineProvider` and returns one `Timeline`. Task 4 replaces this with a proper ActivityConfiguration; Task 5 of the second plan adds the real Home Screen widget. Do not ship the bootstrap-only widget.

  Write `scripts/test-ios.sh` with complete simulator discovery, with no hard-coded device name/ID:

```bash
#!/usr/bin/env bash
set -euo pipefail
SIMULATOR_ID="$(xcrun simctl list -j devices available | python3 -c 'import json,sys; dev=[d for group in json.load(sys.stdin)["devices"].values() for d in group if d.get("isAvailable") and d["name"].startswith("iPhone")]; print(dev[0]["udid"] if dev else "")')"
if [[ -z "$SIMULATOR_ID" ]]; then
  echo "BLOCKED: no iPhone Simulator installed" >&2
  exit 2
fi
xcodebuild -project Hestia.xcodeproj -scheme Hestia -destination "platform=iOS Simulator,id=$SIMULATOR_ID" CODE_SIGNING_ALLOWED=NO "$@"
```

- [ ] **Step 4: Generate and confirm RED before starter implementation.** On Mac run `xcodegen generate` then `xcodebuild -list -project Hestia.xcodeproj` and `bash scripts/test-ios.sh -only-testing:HestiaTests/ProjectSmokeTests test`; the failure should specifically concern absent `StarterCompanion`, **not** broken target/project generation. If no Mac/Xcode or installed simulator exists, record **BLOCKED and STOP execution here**. Never treat a syntax-only check as passing a native smoke test.
- [ ] **Step 5: Add the small `StarterCompanion`/`StarterMascotView` definition above; run GREEN.** `xcodebuild -project Hestia.xcodeproj -scheme Hestia -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build` and `bash scripts/test-ios.sh -only-testing:HestiaTests/ProjectSmokeTests test` must compile app, embedded extension and test target. Inspect generated scheme test action, embedded extension, Info.plist Live Activities key and Group entitlements. Record real output; stop on failure.
- [ ] **Step 6: Review and checkpoint.** Document Mac tool versions and observed commands/results in `README.md` and `docs/PROJECT_STATE.md`. Create a focused Git commit **only when** a Git repo has been intentionally established by its owner; currently there is none. Commit message proposal: `build: establish Hestia native app and test targets`.

## Task 2: Persist companion identity and mode, independently of Island life

**Files:** Create `Shared/HestiaModels.swift`, `App/CompanionPreferencesStore.swift`, `HestiaTests/CompanionPreferencesTests.swift`. Modify `App/HestiaApp.swift` only to inject store.

**Interfaces:** `enum CompanionTask: String, Codable, CaseIterable { case reading, studying, creating }`; `struct CompanionPreferences: Codable, Equatable` with `selectedID: String`, `name: String`, `modeEnabled: Bool`, `reducedMotion: Bool`, `lastTask: CompanionTask`, `lastDuration: TimeInterval`. `final class CompanionPreferencesStore` exposes `func load() throws -> CompanionPreferences`, `func save(_ preferences: CompanionPreferences) throws`, `func setModeEnabled(_ enabled: Bool) throws`; initializer `init(defaults: UserDefaults)` allows isolated XCTest suites. App composition uses `UserDefaults(suiteName: "group.com.example.Hestia")` and **displays an explicit unavailable state if nil**.

- [ ] **Step 1: Write failing storage test.**

```swift
import XCTest
@testable import Hestia

final class CompanionPreferencesTests: XCTestCase {
    func testOnModeSurvivesNewStoreUntilUserStopsIt() throws {
        let suite = "HestiaTests." + UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let first = CompanionPreferencesStore(defaults: defaults)
        XCTAssertFalse(try first.load().modeEnabled)
        try first.setModeEnabled(true)
        XCTAssertTrue(try CompanionPreferencesStore(defaults: defaults).load().modeEnabled)
        try first.setModeEnabled(false)
        XCTAssertFalse(try CompanionPreferencesStore(defaults: defaults).load().modeEnabled)
    }
}
```

- [ ] **Step 2: Run targeted RED test on Mac simulator.** `bash scripts/test-ios.sh -only-testing:HestiaTests/CompanionPreferencesTests test`. Expected compile/test failure until the store exists.
- [ ] **Step 3: Implement least-complex Codable storage.** Default values: starter ID `starter-orb`, name `Mochi`, mode `false`, motion preference `false`, task `creating`, duration `21600` seconds (six hours). Encode/decode the entire preferences object under one stable key `hestia.companion.preferences.v1` in the injected UserDefaults; no network or global singleton. Handle missing data as initial defaults, corrupt data as a visible recoverable storage error (do not silently switch to unrelated preferences). Avoid resetting `modeEnabled` when a session times out.
- [ ] **Step 4: Run GREEN and negative cases.** Repeat targeted test, add `testMissingGroupDefaultsCannotPretendSharedStorageWorks` using a failing injected provider, and `testReopenAfterExpiryKeepsModeEnabled` by re-instantiating the store. Record actual output or block.
- [ ] **Step 5: Review/commit.** Check no personal asset/content logged, and an absent suite is surfaced. Focused commit only if Git available: `feat: persist local companion mode and last activity settings`.

## Task 3: Make single-session timing and restart logic deterministic

**Files:** Create `App/SessionWindowEngine.swift`, `App/SessionWindowStore.swift`, `HestiaTests/SessionWindowEngineTests.swift`, `HestiaTests/SessionWindowStoreTests.swift`. Adjust `Shared/HestiaModels.swift` with the window type.

**Interfaces:** `struct CompanionWindow: Codable, Equatable, Identifiable` with `id: UUID`, `task: CompanionTask`, `start: Date`, `deadline: Date`, `activityID: String?`, `posterKey: String`, `phase: WindowPhase`. `enum WindowPhase: String, Codable, Equatable { case starting, running, elapsed, endPending, finished }`; `enum ActivitySurfaceState: Equatable { case active, stale, ended, dismissed, missing }`. `SessionWindowEngine` exposes `func begin(task: CompanionTask, duration: TimeInterval, at: Date, id: UUID = UUID(), posterKey: String = "starter-orb") throws -> CompanionWindow`, `func reconcile(_ window: CompanionWindow, at: Date, activity: ActivitySurfaceState) -> WindowPhase`, `func canRestart(after window: CompanionWindow, at: Date) -> Bool`. `SessionWindowStore` exposes `load() throws -> CompanionWindow?`, `save(_:) throws` and `clear() throws`, using one Codable record at Group-defaults key `hestia.session.window.v1`; Task 4 owns transition updates and endPending. The default poster key tells both targets to draw the same starter vector. Later custom art freezes a PNG under the same `id` and supplies its immutable key **before** request.

- [ ] **Step 1: Write failing edge-condition tests.**

```swift
import XCTest
@testable import Hestia

final class SessionWindowEngineTests: XCTestCase {
    func testSixHoursExpiresWithoutTurningCompanionModeOff() throws {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let engine = SessionWindowEngine()
        let window = try engine.begin(task: .reading, duration: 21_600, at: now)
        XCTAssertEqual(window.deadline, now.addingTimeInterval(21_600))
        XCTAssertEqual(engine.reconcile(window, at: now.addingTimeInterval(21_601),
                                       activity: .active), .elapsed)
        XCTAssertTrue(engine.canRestart(after: window, at: now.addingTimeInterval(21_601)))
    }
    func testRejectsOverEightHours() {
        XCTAssertThrowsError(try SessionWindowEngine()
            .begin(task: .studying, duration: 28_801, at: Date()))
    }
}
```

- [ ] **Step 2: Run targeted RED.** `bash scripts/test-ios.sh -only-testing:HestiaTests/SessionWindowEngineTests test`.
- [ ] **Step 3: Implement minimal pure state policy and durable store.** Durations must be positive, finite and `<= 28_800` seconds; apply a safety buffer when deciding production eight-hour maximum if device tests require it. `begin` uses explicit/generated UUID and starter/file poster key, deadline and phase `.starting`. `SessionWindowStore` encodes the whole current window as a **single** Codable value in injected suite UserDefaults; write UUID/deadline/posterKey **before** invoking ActivityKit, then update activity ID and phase after request. An elapsed deadline yields `.elapsed` even if ActivityKit still reports `.active`; `.stale` is not ended; dismissed doesn't automatically erase local task. **Pure `canRestart` is only logical eligibility**, and the coordinator must end/reconcile old ActivityKit presentation before next request.
- [ ] **Step 4: GREEN and failure-path tests.** Add cases for invalid 0/negative/NaN, duplicate rapid Start rejection, stale not automatic end, dismissed card vs still-running local task, persisted `.endPending`, new UUID on renewal. Add a `SessionWindowStoreTests.testCrashAfterRequestBeforeSavingActivityIDRecoversUUID` test: write a starting window with `activityID == nil`, instantiate a **new store** from the same test suite, assert UUID/deadline/posterKey survived, and use a fake ActivityKit client returning a matching static `sessionID` to recover ID without another request. Verify Group suite load failure is explicit and never silently overwrites. Rerun targeted suites. `CompanionPreferences.modeEnabled` remains unchanged by engine/store transitions.
- [ ] **Step 5: Review/commit.** No timers/background workers in pure engine. Commit when available: `feat: model bounded companion windows and restart rules`.

## Task 4: Add the native ActivityKit bridge and system presentation

**Files:** Create `App/LiveActivityClient.swift` and `HestiaTests/LiveActivityClientTests.swift`; update `Shared/HestiaModels.swift`, `Widget/HestiaWidgets.swift`, `project.yml` and app/extension Info and entitlements only as the generator demands.

**Interfaces:** `struct HestiaActivityAttributes: ActivityAttributes` with immutable `sessionID: String`, `task: String`, `companionName: String`, `posterKey: String`, `start: Date`, `deadline: Date`; nested `ContentState: Codable, Hashable` with only mutable `phase: String` (no redundant deadline in state). `protocol LiveActivityClient`: `func enabled() -> Bool`, `func start(_ window: CompanionWindow, companionName: String) async throws -> String`, `func end(id: String) async -> ActivitySurfaceState`, `func matching(sessionID: UUID) async -> [LiveActivitySnapshot]`, where `LiveActivitySnapshot` includes `id: String` and `state: ActivitySurfaceState`. Native implementation wraps `Activity<HestiaActivityAttributes>` and `ActivityAuthorizationInfo`; tests use a fake. Return ID but also reconcile by static UUID after crash. `end` is nonthrowing native async ActivityKit; wrapper reports observed post-end state. If still active/stale or interrupted, persist `.endPending` for later reconciliation.

- [ ] **Step 1: Write RED fake-adapter tests** in `HestiaTests/LiveActivityClientTests.swift`:

```swift
import XCTest
@testable import Hestia

final class LiveActivityClientTests: XCTestCase {
    func testRejectedAuthorizationDoesNotRequestIsland() async throws {
        let fake = FakeLiveActivityClient(isEnabled: false)
        let coordinator = LiveSessionCoordinator(client: fake)
        let result = await coordinator.start(task: .reading, duration: 21_600,
                                             name: "Mochi", at: Date())
        XCTAssertEqual(result, .unavailable)
        XCTAssertEqual(fake.requests, 0)
    }
}
```

  Define `enum LiveStartResult: Equatable { case started(String), unavailable, failed }` in the app; `FakeLiveActivityClient` should be minimal and owned by this test file.
- [ ] **Step 2: Confirm RED with targeted test.** Use `bash scripts/test-ios.sh -only-testing:HestiaTests/LiveActivityClientTests test`.
- [ ] **Step 3: Implement client/coordinator and view layouts.** Check `ActivityAuthorizationInfo().areActivitiesEnabled`; only when enabled make an explicit foreground `Activity.request(attributes:content:pushType:)` with small attributes/state. Write `SessionWindowStore.save` with UUID, deadline, posterKey and `.starting` **before** request; update activity ID and phase `.running` afterward. On relaunch, if ID is nil, `matching` finds `Activity<HestiaActivityAttributes>.activities` by immutable `sessionID` rather than making a duplicate request. End using documented `await activity.end(ActivityContent(state: finalState, staleDate: nil), dismissalPolicy: .immediate)` for user Stop or appropriate default policy for genuine task completion; **nonthrowing async**. Afterward read observed ActivityKit state; if an active result is still observed, persist `.endPending` instead of pretending the Island disappeared. Apple reference: https://developer.apple.com/documentation/activitykit/activity/end%28_%3Adismissalpolicy%3A%29 .

  **Explicit renewal gate:** if the six-hour logical task has elapsed but the old ActivityKit activity still reports active/stale (within Apple's eight-hour limit), a tap on Restart must **first request end of the old Activity and reconcile**. Until it is ended/dismissed or safely absent, show "Finishing previous session" and do not make a new Activity.request. Same gate applies to repeated taps and restart after app crash. Widget extension: `ActivityConfiguration(for: HestiaActivityAttributes.self)` shows Lock Screen label "Reading ends at 4:00" and date-driven `Text(timerInterval:)`; dynamicIsland compactLeading uses original Shared vector glyph for `posterKey == "starter-orb"`, compactTrailing native time, minimal glyph, expanded pet/task/time. For tiny states use stable image and descriptive text; no per-frame updates or custom idle loops. Add `widgetURL` for `hestia://session`, route to app.
- [ ] **Step 4: GREEN + no-hardware semantics.** Test denied request, native error, duplicate ID recovery, stale/dismissed/ended mapping and simulated end-not-observed (`FakeLiveActivityClient.end` returns `.active`), which must leave `.endPending` and **zero new requests**. Confirm a subsequent reported end permits exactly **one** new Activity.request with fresh UUID and previously saved task/duration; test double rapid Restart tap. Rerun fake suite and simulator extension build. On non-Island hardware, Lock Screen remains useful. No custom Island animation/visibility claims until signed device observation.
- [ ] **Step 5: Review/commit.** Confirm the extension is embedded, app and extension share only expected file resources, attributes are small, timer at zero doesn't assert automatic completion, and there is no APNs/background loophole. Commit when available: `feat: add bounded ActivityKit companion sessions and Island surfaces`.

## Task 5: Build the 60-second character-first journey and one-tap renewal

**Files:** Create `App/CompanionHomeView.swift`, `HestiaUITests/CompanionFlowUITests.swift`; modify `App/HestiaApp.swift` and coordinator/store glue as needed. No import flow yet; its button may be visibly labeled "Import artwork" with an accessible statement that import is a later increment, but **do not pretend it works**.

**Interfaces:** View actions `chooseStarter()`, `setModeEnabled(_:)`, `startTask(_ task: CompanionTask, seconds: TimeInterval)`, `restartPreviousTask()`, `endTask()`, `stopCompanionMode()`. All route through store and coordinator from Tasks 2–4; no logic that creates activities directly inside View body. Accessible labels: "Start Companion Mode", "Start Island session", "Restart Island session", "End Island session", "Stop Companion Mode".

- [ ] **Step 1: Write RED UI test** in `HestiaUITests/CompanionFlowUITests.swift`:

```swift
import XCTest

final class CompanionFlowUITests: XCTestCase {
    func testStarterCanEnableCompanionModeWithoutAnAccount() {
        let app = XCUIApplication()
        app.launchArguments += ["-hestia-ui-test-reset"]
        app.launch()
        app.buttons["Choose Mochi"].tap()
        app.buttons["Start Companion Mode"].tap()
        XCTAssertTrue(app.buttons["Stop Companion Mode"].exists)
        XCTAssertFalse(app.staticTexts["Sign in required"].exists)
    }
}
```

  Implement the special launch argument in `HestiaApp` under `#if DEBUG` only so UI tests start clean; production must not expose a reset handler.
- [ ] **Step 2: Run UI RED** with `bash scripts/test-ios.sh -only-testing:HestiaUITests/CompanionFlowUITests test`.
- [ ] **Step 3: Implement minimal UI.** Welcome with original mascot and "Choose Mochi"; Companion Home with separate persistent mode toggle and actual activity buttons; authentic task choices reading/studying/creating with proposed six-hour default; a Lock Screen art-visibility preview before first session; timer and label that refer to task end time; ActivityKit disabled = in-app countdown + Settings advice; request failure = Retry; non-Island = Lock Screen. Tap/end failures visibly acknowledged. Native accessibility text styles/VoiceOver, Reduce Motion and still pose. In-app original mascot may animate with a *subtle* SwiftUI expression while the scene is active and motion is allowed, distinct from the static Island view; disable it on Reduce Motion and explicit preference. Navigation from `hestia://session` opens management.
- [ ] **Step 4: GREEN + restart tests.** Extend UI test to expire task using injected clock/client **only for tests**, reopen app, assert "Restart Island session", tap once and assert one new request with same genuine task/duration; test Stop Companion Mode ends in-app task. Add unit tests for double tap and group-store error. Do not make tests depend on waiting real six hours.
- [ ] **Step 5: Manual first-use observation and commit.** Watch starter path on a simulator within about one minute, separate from imported GIF adoption (next plan). Confirm no claim of system success on failure. Record observations and commit when available: `feat: deliver companion onboarding and explicit Island renewal`.

## Task 6: Real-device evidence and release-blocker checklist

**Files:** Update `docs/GAP_ANALYSIS.md`, `docs/TEST_PLAN.md`, `docs/PROJECT_STATE.md`, `README.md`; patch only failures documented in this increment and rerun relevant tests.

**Interfaces:** Deliver a reproducible core on eligible/noneligible hardware and a stored evidence table. No new app feature.

- [ ] **Step 1: Run generation, build and XCTest on a Mac.** Capture exact XcodeGen, Xcode, simulator runtime and command output. Run `xcodegen generate`, `xcodebuild -project Hestia.xcodeproj -scheme Hestia -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build` and targeted test suites plus `HestiaUITests`.
- [ ] **Step 2: Sign with owned identifiers.** On Mac with a real developer team, replace scaffold-only bundle/App Group identifiers consistently and verify *both targets* possess the same entitled Group container. Never copy arbitrary team IDs or commit secrets.
- [ ] **Step 3: Exercise native surfaces on two devices.** Eligible Island iPhone: start 6-hour window, compact leading/trailing/minimal/expanded, tap/deep-link, genuine task name, date countdown, authorization off, dismissal, competing Live Activities and Always-On. Non-Island iPhone: Lock Screen fallback. Both: VoiceOver, extra-large Dynamic Type, light/dark, Reduce Motion.
- [ ] **Step 4: Exercise recovery and length limit.** Start, background/force-quit, relaunch; end failure/pending; 8-hour iOS cap (can accelerate local pure-clock tests but **real ActivityKit cap requires actual system observation**); one-tap manual restart after expiry; ensure expired Countdown at zero doesn't imply background completion. Capture device/iOS/software and evidence.
- [ ] **Step 5: Independent spec + quality review and gate.** Reviewer must match all **core** acceptance clauses to evidence, assess policy fit of genuine task, report unresolved blockers and test logs. Record **NOT VERIFIED** where actual signed device checks cannot be run; never call release ready. Focused docs commit only with owner-authorized Git repository.

## Core completion and handoff

Core is complete **only** if original starter was reconciled or approved replacement scaffolding was used, unit/UI tests pass in a real Xcode toolchain, signed device checks cover Island and non-Island behavior, one-tap restart works, and the user journey matches the approved design without fake visibility promises. **No tests or implementation have been performed as of plan creation.**

After core review, proceed to the separately approved [custom art and snapshot widget plan](2026-10-15-companion-art-and-widget.md). That second plan is not permission to skip the first plan's signed extension/App Group gates.
