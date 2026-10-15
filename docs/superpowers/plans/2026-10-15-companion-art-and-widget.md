# Hestia Custom Art and Snapshot Widget Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Status:** **APPROVED FOR EXECUTION** by user on 2026-10-15, **but blocked on the core plan's passing native test/device gates**. This second increment is not permitted to run while core verification is missing.

**Goal:** Let users privately import PNG/JPEG/GIF characters, play valid GIF animation in the foreground app, render a safe still in Island/Lock Screen and a secondary Home Screen widget, and preserve the correct art throughout each session's lifetime.

**Architecture:** A bounded native Image I/O decoder validates selected data before local storage. One shared asset repository stores original user art in the app sandbox and small derived PNG posters in the entitled App Group for WidgetKit. Existing core Companion Mode/ActivityKit logic references immutable session-specific poster keys; user imports never rewrite an in-use Activity image.

**Tech Stack:** iOS 17+ SwiftUI, PhotosUI, UniformTypeIdentifiers, Image I/O, UIKit/ImageRenderer as necessary, WidgetKit, App Groups, XCTest and XcodeGen. No account, remote uploads, asset-scraping or third-party animation engine.

**Spec:** `docs/superpowers/specs/2026-10-15-island-first-companion-design.md`, especially import, privacy, GIF/system split, accessibility and poster lifecycle.

**Dependency:** [Core Island implementation plan](2026-10-15-island-companion-core.md) must have approved and verified its key interfaces: `CompanionPreferences`, `CompanionWindow`, `HestiaActivityAttributes`, `CompanionPreferencesStore` and `LiveActivityClient`. If those interfaces differ once actual app exists, reconcile this plan **before executing**; do not create a parallel store or duplicate widget extension.

## Global Constraints

- Import **only media explicitly chosen by the user** through PhotosPicker/Files. Local storage only, no broad Photos permissions and no uploads. Original starter art must be licensed/original.
- Support valid PNG, JPEG, GIF; images with unusual extensions must be validated by actual decoded data/type. Corrupt, oversized or decompression-heavy files must produce non-destructive errors.
- **GIF animation is foreground in-app only**. The Island, Lock Screen Live Activity and Home Screen widget use a **representative PNG still**; importing an arbitrary GIF does not create synthetic blink/cheer poses.
- UIKit/Image I/O decoding must be bounded and pause when app is backgrounded or Reduce Motion/animated-image playback preference disables it.
- Use app-owned storage plus one shared App Group container with matching entitlements; never silently choose unrelated storage on Group failure. A selected art switch must not mutate an in-use session poster.
- Apple controls WidgetKit refresh timing; show helpful manual Add Widget instructions without implying Hestia can pin a widget automatically or display an endless GIF loop.
- Do not log file contents, thumbnails, picked URLs or artwork binary data. Lock Screen previews must disclose possible visibility of imported art to people looking at the locked device.
- Current Windows session has **no Xcode, simulator, signed hardware or app code**. Plan steps and test commands have not run; Mac/device evidence is mandatory.

## Review Focus

1. **Small encoded, huge decoded GIF or malicious dimensions/frame count:** reject before allocating frame arrays; keep the previous companion and show a friendly reason (Task 1).
2. **PhotosPicker transcodes a GIF to PNG or iCloud art is offline:** do not claim moving art was imported; show still or offer Files fallback and retry (Tasks 1 and 4).
3. **App terminated during security-scoped file import:** close scope reliably, never leave a source URL reference or partial shared poster (Tasks 1 and 3).
4. **User selects new pet while old Live Activity still uses old poster:** old Lock Screen/Island image remains correct until safe cleanup, including extra Lock Screen retention after end (Task 3).
5. **Widget extension cannot read shared Group or has a stale timeline:** accessible fallback shows original still and accurate status; never infer immediate refresh or wrong personal image (Tasks 3–5).

## File map — proposed, reconcile with actual core

| File | Role |
|---|---|
| `App/ArtworkImportService.swift` | Format/type and resource preflight, copying the original to sandbox |
| `App/ArtworkSourcePicker.swift` | PhotosPicker/Files picker flow and privacy/errors |
| `App/GIFPlaybackView.swift` | Validated frame timings, bounded cache and motion-aware foreground playback |
| `App/CompanionHomeView.swift` | Import action, preview, renaming and selected-art handling |
| `App/SharedPosterStore.swift` | Generates/stores representative PNG in Group, immutable per-session snapshots, cleanup |
| `Shared/HestiaModels.swift` | Extend companion identity with local poster reference; no raw photo in ActivityKit state |
| `Widget/HestiaWidgets.swift` | Small/medium Home Screen snapshot WidgetKit timeline using shared poster |
| `HestiaTests/ArtworkImportTests.swift` | Valid/corrupt/bomb/offline/Photos/Files error mapping tests |
| `HestiaTests/GIFPlaybackTests.swift` | Frame counts, frame durations, memory bounds and motion behavior |
| `HestiaTests/SharedPosterStoreTests.swift` | Atomic write, selected vs session poster, cleanup/denial |
| `HestiaUITests/ImportAndWidgetUITests.swift` | Import selection/preview, widget instructions, motion/accessibility |

## Task 1: Safely validate and import PNG/JPEG/GIF data

**Files:** Create `App/ArtworkImportService.swift`, `HestiaTests/ArtworkImportTests.swift`. Extend `Shared/HestiaModels.swift` with `ImportedArtwork` metadata and local file key. No UI/photo permission in this task.

**Interfaces:** `enum ArtworkImportError: Error, Equatable { case unsupported, corrupt, tooLarge, unavailable, sharedStorageUnavailable }`; `struct ValidatedArtwork { let originalFileName: String; let posterPNG: Data; let frameCount: Int; let animated: Bool }`; `protocol ArtworkImporting { func importData(_ data: Data, suggestedName: String) throws -> ValidatedArtwork }`. Importer writes the validated original only to the **app sandbox** and derives PNG **data**, not a Group file/key. `SharedPosterStore` in Task 3 is the **sole writer of Group poster keys**. Selected companion metadata is updated **only after** both operations succeed. `ArtworkImportService` accepts an isolated app sandbox root for XCTest. Use Image I/O `CGImageSourceCreateWithData` and `CGImageSourceGetType/Count`, not filename-extension trust.

- [ ] **Step 1: Write RED tests for frame fidelity and malformed input.**

```swift
import XCTest
@testable import Hestia

final class ArtworkImportTests: XCTestCase {
    func testRejectsInvalidBytesAsCorrupt() throws {
        let service = ArtworkImportService(root: FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString))
        XCTAssertThrowsError(try service.importData(Data([0x00, 0x01, 0x02]),
                                                       suggestedName: "friend.gif")) { error in
            XCTAssertEqual(error as? ArtworkImportError, .corrupt)
        }
    }
    func testRejectsEncodedFileLargerThanSafetyLimit() throws {
        let service = ArtworkImportService(root: FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString))
        let large = Data(count: 15_728_641)
        XCTAssertThrowsError(try service.importData(large, suggestedName: "oversize.png")) { error in
            XCTAssertEqual(error as? ArtworkImportError, .tooLarge)
        }
    }
}
```

- [ ] **Step 2: Run RED on a discovered simulator** with `bash scripts/test-ios.sh -only-testing:HestiaTests/ArtworkImportTests test`. The core plan's helper discovers a real simulator and reports BLOCKED if none is installed.
- [ ] **Step 3: Minimal Image I/O preflight and private storage.** Candidate safety ceiling: encoded **15 MiB**, width/height **4096 px** each, GIF frame count **120** and an upper bound of **128 MiB** for a conservative combined preflight decoded-frame estimate. First reject size by `data.count` before opening a source, so the 15,728,641-byte test specifically returns `.tooLarge` even if bytes aren't a valid image. Create the Image I/O source with `kCGImageSourceShouldCache: false`, query top-level and **each frame's actual dimensions**/frame durations without eagerly materializing a frame buffer, and compute `Int64` products with `multipliedReportingOverflow` checks. Add headroom for source decode, UIImage/CGImage copies, compositing and caching; the estimate is **not** measured peak RSS. These ceilings are prototype defaults, not Apple guarantees; revise only with actual device memory data. Accept only `UTType.png`, `.jpeg`, `.gif` according to actual decoded type. Safely write original approved data to unique app-sandbox file atomically; generate one small PNG poster using downsampled `CGImageSourceCreateThumbnailAtIndex`. No Group poster file here. Never replace selected record until new original, valid poster, Group publication and preference update all succeed.
- [ ] **Step 4: GREEN + adversarial fixtures.** Generate tiny valid 2-frame GIF and transparent PNG/JPEG fixtures locally in test code using Image I/O; assert frame count/source type preserved, corrupted/truncated data returns `.corrupt`, size guard returns **exactly** `.tooLarge`, fake extension doesn't bypass decoding, frame sizes/durations/overflows are bounded, no eager frame decode is triggered by preflight, and disk-write failure preserves previous app-sandbox files. An additional integration test with an injected failing `CompanionPreferencesStore` proves the **previous selected companion remains** when new import or Group publication fails; the stand-alone import service must not secretly alter selection. Re-run targeted tests and document measured memory ceilings on simulator/device.
- [ ] **Step 5: Review/commit.** Ensure no file contents or user path in diagnostics; explicit import error leaves selected companion unchanged. Commit if Git exists: `feat: validate and store user-selected companion artwork`.

## Task 2: Show animation inside Hestia and a still everywhere else

**Files:** Create `App/GIFPlaybackView.swift`, `HestiaTests/GIFPlaybackTests.swift`; modify `App/CompanionHomeView.swift` only to preview; no WidgetKit changes yet.

**Interfaces:** `struct GIFFrame { let cgImage: CGImage; let delay: TimeInterval }`; `struct ValidatedAnimation { let source: CGImageSource; let frameCount: Int; let delays: [TimeInterval]; let poster: CGImage }`; `protocol GIFFrameDecoding { func validate(_ source: CGImageSource) throws -> ValidatedAnimation; func frame(at index: Int, from animation: ValidatedAnimation, maxPixelSize: Int) throws -> GIFFrame }`. Avoid an API that returns **all decoded frames** up front. `struct AnimationPlaybackPolicy { let motionAllowed: Bool; func visibleFrameIndex(elapsed: TimeInterval, frameDurations: [TimeInterval]) -> Int }` selects zero with no motion; otherwise uses elapsed modulo positive clamped durations and cumulative boundaries. `GIFPlaybackView` uses a bounded current/next-frame cache, static poster, background pause and no repeated eager decodes.

- [ ] **Step 1: Write RED tests** in `HestiaTests/GIFPlaybackTests.swift`:

```swift
import XCTest
@testable import Hestia

final class GIFPlaybackTests: XCTestCase {
    func testMotionDisabledChoosesStillFrame() {
        XCTAssertEqual(AnimationPlaybackPolicy(motionAllowed: false).visibleFrameIndex(
            elapsed: 9.0, frameDurations: [0.2, 0.3]), 0)
    }
    func testFrameIndexRespectsVariableDurations() {
        XCTAssertEqual(AnimationPlaybackPolicy(motionAllowed: true).visibleFrameIndex(
            elapsed: 0.25, frameDurations: [0.2, 0.3]), 1)
    }
}
```

- [ ] **Step 2: Run RED** with `bash scripts/test-ios.sh -only-testing:HestiaTests/GIFPlaybackTests test`.
- [ ] **Step 3: Implement bounded playback.** Use Image I/O frame properties, clamp invalid/zero delay to an accessible safe minimum (initially **0.10 s**), and request only the current/next frame via downsampling at ≤1024 px, with a small fixed-size cache **rather than decoding every GIF frame into UIKit views**. Before each decode check per-frame size and combined retained buffers (plus conservative transient headroom); evict frames on background or memory warning. Refuse to play a file if frame caches plus transient buffers would exceed the conservative **128 MiB** prototype ceiling. Stop its scheduling on `scenePhase != .active`, `accessibilityReduceMotion`, disabled animated-image preference or in-app "Reduce character motion" setting. Expose only the poster still to extension callers. Never schedule WidgetKit timelines every animation frame.
- [ ] **Step 4: GREEN + UI checks.** Test a 2-frame GIF with durations 0.2 and 0.3 seconds, a one-frame GIF, missing timing, transparency and preview after return from background; compare still to first useful frame. On real device record measured decoded memory and scrolling smoothness before adjusting initial caps.
- [ ] **Step 5: Review/commit.** Ensure no battery-heavy run loop offscreen, no frame data in ActivityKit; commit if available: `feat: preview motion-aware GIF companions inside Hestia`.

## Task 3: Share stable posters safely with the extension

**Files:** Create `App/SharedPosterStore.swift`, `HestiaTests/SharedPosterStoreTests.swift`. Modify `Shared/HestiaModels.swift` and the core's start/end wiring as needed; coordinate ActivityKit changes with core owner.

**Interfaces:** `protocol PosterStore { func saveSelectedPoster(_ png: Data, companionID: String) throws -> String; func freezePosterForSession(from selectedKey: String, sessionID: UUID) throws -> String; func readPoster(key: String) throws -> Data; func cleanUnusedPosters(activityStates: [LiveActivitySnapshot], now: Date) throws }`. Reference keys are **immutable UUID-based relative filenames** in the matched app-group container, never arbitrary paths. `saveSelectedPoster` creates a new key on each successful artwork revision; it never overwrites the prior selected file in place. Store one **atomic selection record** in `CompanionPreferences` containing `name`, `selectedPosterKey: String?` and `selectionRevision: UUID`, with migration of the core preferences v1 record (existing starter retains the `starter-orb` sentinel until customized). Read the name/key/revision as one transaction in WidgetKit; stale timeline entries point to an immutable old key or an honest missing-art fallback, never to new unrelated art. Before a new live activity, allocate `sessionID = UUID()`, freeze a unique poster with this same UUID, then call `SessionWindowEngine.begin(task:duration:at:id:posterKey:)` with that exact key, persist the window, and only then request ActivityKit. On any failure, don't publish partial selection; keep a failed-start frozen poster until no in-flight/recovered ActivityKit request can reference it.

- [ ] **Step 1: Write RED immutable poster test** in `HestiaTests/SharedPosterStoreTests.swift`:

```swift
import XCTest
@testable import Hestia

final class SharedPosterStoreTests: XCTestCase {
    func testNewSelectionDoesNotOverwriteActiveSessionPoster() throws {
        let store = try SharedPosterStore(root: FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString))
        let png = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
            .pngData { context in UIColor.purple.setFill(); context.fill(CGRect(x: 0, y: 0, width: 1, height: 1)) }
        let selected = try store.saveSelectedPoster(png, companionID: "oc-1")
        let frozen = try store.freezePosterForSession(from: selected, sessionID: UUID())
        let newer = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1))
            .pngData { context in UIColor.orange.setFill(); context.fill(CGRect(x: 0, y: 0, width: 1, height: 1)) }
        _ = try store.saveSelectedPoster(newer, companionID: "oc-1")
        XCTAssertEqual(try store.readPoster(key: frozen), png)
    }
}
```

  Include `import UIKit` at file top for this tiny **valid PNG** fixture; also test malformed PNG is rejected rather than legitimizing arbitrary bytes.
- [ ] **Step 2: Run targeted RED** with `bash scripts/test-ios.sh -only-testing:HestiaTests/SharedPosterStoreTests test`.
- [ ] **Step 3: Implement atomic Group storage.** Use `FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.example.Hestia")` (switch to owned identifier only with signed setup), fail explicitly when unavailable, validate relative keys to prevent path traversal, publish a **new immutable filename** for each selected revision via temporary-file atomic rename; do not overwrite an existing key. Session poster uses unique session UUID and is never mutated. Publish new `CompanionPreferences` record containing selected name/key/revision **after** all file writes succeed. Existing widget timelines still read their old immutable key until iOS reloads them; keep old selected posters for a conservative retention window (initially ≥24 hours, adjusted after device observation), with an honest missing-art fallback if ultimately purged. Session snapshots require a **single reconciled cleanup method** that reads stored end timestamps and ActivityKit state; retain until **at least four hours after actual end** *and* no active/retained Activity references. No caller-supplied `noActivityReferences` boolean can authorize early deletion. Cleanup only when the app can actually run; never assume a background worker. For explicit user deletion of personal artwork, try ActivityKit end with immediate dismissal and reconcile; if unable, explain Lock Screen residual visibility before any forced purge.
- [ ] **Step 4: GREEN and failure tests.** Add cases for Group container nil, read failures, invalid key (`../private`), malformed "PNG", partial writes, active/ended-but-still-on-Lock-Screen poster retention, recent selected revisions, atomic name/key/revision reads with old widget snapshot, import replacement and cleanup only after safe end. Assert a window's `posterKey` is the frozen file and doesn't change when selection switches. On signed hardware test real app → extension read, not just temporary-folder tests.
- [ ] **Step 5: Review/commit.** Check asset rights, no logs or network; commit if available: `feat: preserve companion posters across widget and activity life`.

## Task 4: Wire Photos/Files import and in-app recovery UX

**Files:** Create `App/ArtworkSourcePicker.swift`, `HestiaUITests/ImportAndWidgetUITests.swift`; modify `App/CompanionHomeView.swift` and app selection store. No broad Photos authorization.

**Interfaces:** `func acceptPickedData(_ data: Data, suggestedName: String) throws` routes through `ArtworkImporting` and `PosterStore`; no direct file writes from View. Photos picker must use original-data transfer where available and validate actual imported format. Files picker security-scoped resources must be scoped to a `defer` cleanup inside the import operation.

- [ ] **Step 1: RED integration tests** with a test fixture import path (available only under `#if DEBUG`):

```swift
import XCTest

final class ImportAndWidgetUITests: XCTestCase {
    func testInvalidImportDoesNotEraseExistingCompanion() {
        let app = XCUIApplication()
        app.launchArguments += ["-hestia-ui-test-reset", "-hestia-ui-test-invalid-image"]
        app.launch()
        app.buttons["Choose Mochi"].tap()
        app.buttons["Import artwork"].tap()
        XCTAssertTrue(app.staticTexts["Choose another image"].exists)
        XCTAssertTrue(app.staticTexts["Mochi"].exists)
    }
}
```

- [ ] **Step 2: Run RED UI suite** with `bash scripts/test-ios.sh -only-testing:HestiaUITests/ImportAndWidgetUITests test`.
- [ ] **Step 3: Implement pickers and honest previews.** Define `-hestia-ui-test-invalid-image` as a **DEBUG-only injected import-data seam**: when the user taps "Import artwork" in UI test mode, pass `Data([0x00,0x01,0x02])` through the **real ArtworkImporting validation path** instead of opening an OS picker; production builds cannot access it. PhotosPicker uses original encoding preference, validates transferred bytes and frame count; if GIF becomes PNG, explain lost motion/offer Files route, not a false moving-image claim. Files `fileImporter` accepts PNG/JPEG/GIF: call `startAccessingSecurityScopedResource`, **copy/read the entire picked file into app-owned storage synchronously before releasing scope** with `defer { stopAccessingSecurityScopedResource() }`; only afterward perform asynchronous validation of the app-owned bytes. If security access is denied or the picker is cancelled, preserve prior selection. Never pass the original security-scoped URL into escaping async work after scope release. Name and confirm before switching character; publish the group poster/new selection atomically as defined in Task 3. Surface unavailable iCloud/offline retry. Disclose "Your imported art may appear on your Lock Screen while the session is active."
- [ ] **Step 4: GREEN + privacy walk-through.** Test valid PNG/JPEG/GIF, selected animation inside Hestia vs static Island poster, an unavailable cloud asset, explicit privacy notice and motion disabled. Unit-test picker mapping separately from OS UI; manually exercise real Photos/Files pickers on iPhone, including iCloud and security-scope release.
- [ ] **Step 5: Review/commit.** Ensure no Photos full-library prompt, no public sharing, no asset URL leaks; commit if available: `feat: import personal companions from Photos and Files`.

## Task 5: Add the secondary Home Screen WidgetKit snapshot

**Files:** Modify `Widget/HestiaWidgets.swift`, `App/CompanionHomeView.swift`; create `HestiaTests/WidgetSnapshotTests.swift`. No new extension target; reuse core extension.

**Interfaces:** `struct CompanionWidgetEntry: TimelineEntry { let date: Date; let companionName: String; let posterKey: String?; let selectionRevision: UUID }`. `struct WidgetSnapshotState: Equatable { let displayName: String; let useStarterIllustration: Bool; let missingCustomArtwork: Bool }` and `struct WidgetSnapshotPolicy { func resolve(selectedName: String, selectedIsStarter: Bool, readablePosterData: Data?) -> WidgetSnapshotState }` can be unit-tested in a Shared file compiled into app/extension. `CompanionWidgetProvider: TimelineProvider` **atomically reads one selected name/key/revision record** and emits a static small/medium entry referencing that immutable key. A missing custom poster displays a neutral unavailable-art glyph with the actual custom name; **never render another person's/starter character as if it were the chosen imported art**. Request `WidgetCenter.shared.reloadTimelines(ofKind: "HestiaCompanion")` after a confirmed selection change without promising reload timing.

- [ ] **Step 1: RED snapshot provider test** in `HestiaTests/WidgetSnapshotTests.swift`:

```swift
import XCTest
@testable import Hestia

final class WidgetSnapshotTests: XCTestCase {
    func testMissingCustomPosterKeepsNameButNeverShowsWrongMascot() {
        let state = WidgetSnapshotPolicy().resolve(
            selectedName: "Nia", selectedIsStarter: false, readablePosterData: nil)
        XCTAssertEqual(state.displayName, "Nia")
        XCTAssertFalse(state.useStarterIllustration)
        XCTAssertTrue(state.missingCustomArtwork)
    }
}
```

  Keep `WidgetSnapshotPolicy` in a shared, unit-testable non-extension-specific file; WidgetKit view renders the resolved state without requiring an extension in the unit test.
- [ ] **Step 2: Run RED unit suite** with `bash scripts/test-ios.sh -only-testing:HestiaTests/WidgetSnapshotTests test`.
- [ ] **Step 3: Add small/medium WidgetKit kind.** Produce fixed static poster/name with immutable name/key/revision snapshot, meaningful accessibility description, margins and tinted dark/light treatment. If custom art is missing show labeled neutral silhouette, not another selected pet. Use reasonable timeline policy and WidgetCenter reload request; **do not schedule every GIF frame** or promise refresh arrival time. Show in-app Add Widget **instructions**, not a fake button that installs a widget. Keep Live Activity configuration intact.
- [ ] **Step 4: GREEN + native widget acceptance.** Simulate available/unavailable poster, selection switch and no session. Manually add small and medium widgets on an iPhone, request reload, observe actual delay and tinted/Always-On variants where supported. Confirm imported image does not animate in widget.
- [ ] **Step 5: Review/commit.** Recheck Info.plist/entitlement sharing and extension target embedding, then commit when available: `feat: show selected companion in snapshot Home Screen widget`.

## Task 6: Real-device security, accessibility and end-to-end verification

**Files:** Update `docs/GAP_ANALYSIS.md`, `docs/TEST_PLAN.md`, `docs/PROJECT_STATE.md`, `README.md`; fix only verified findings in app/extension and rerun affected tests.

**Interfaces:** Completes the approved MVP cross-surface import/animation/widget acceptance; no new features.

- [ ] **Step 1: Mac build and tests.** `xcodegen generate`; `xcodebuild -project Hestia.xcodeproj -scheme Hestia -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build`; run focused unit/UI test suites on a discovered installed simulator. Record actual command/results, not generic "passed."
- [ ] **Step 2: Signed hardware + import matrix.** Use a real Dynamic Island iPhone and non-Island iPhone; with matching Group entitlements import PNG/JPEG/small transparent GIF, corrupt/oversized/unknown data, offline iCloud asset and Files-picked media. Check frame preservation, app-only motion, shared representative poster, memory and thermal usage.
- [ ] **Step 3: Lifecycle and privacy matrix.** Change art mid-session; verify old immutable poster on Lock Screen/Island and fresh art in the next real window. End/restart/expire session, handle missing Group/storage, confirm no upload and truthful Lock Screen disclosure. Add Home Screen widget manually and observe snapshots/tint/refresh delays.
- [ ] **Step 4: Accessibility + license audit.** VoiceOver with imported art labels, Dynamic Type/large sizes, Reduce Motion/disabled animated images, dark/light, Always-On, offline and error recovery. Validate all starter illustrations are original or licensed and that importing user art stays private.
- [ ] **Step 5: Independent spec/quality review and checkpoint.** Another reviewer verifies cross-surface acceptance, rechecks every approved-spec item and notes any App Review/licensing/power blockers. Mark features **NOT VERIFIED** if Mac/hardware tests are unavailable; never call the MVP App Store ready on unit tests alone.

## Complete MVP gate

The approved written Hestia design is satisfied only if **both** core and art/widget plans have passed their native and on-device verification, the app remains character-first with user-stopped persistent Companion Mode, actual Island windows are genuine finite activities with explicit one-tap restart, GIFs only animate in-app, and the user can import local art with safe shared stills. All steps in this file are **unstarted** as of October 15, 2026.
