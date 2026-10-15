# Hestia — Island-first companion: product and native UX design

**Status: WRITTEN DESIGN APPROVED BY USER — 2026-10-15.** Drafted and explicitly approved October 15, 2026, after agreement on one-tap restart of a genuine time-bounded Island session. **Design approval authorizes gap analysis and implementation planning, not app-code changes. Separate plan approval is required.** No build or device behavior has been verified. Companion source code is absent in the selected workspace.

Canonical design for this proposal. Supporting files: [Product brief](../../PRODUCT_BRIEF.md), [MVP scope](../../MVP_SCOPE.md), [UX notes](../../UX_SPEC.md), [Apple capability matrix](../../IOS_CAPABILITY_MATRIX.md), [Research](../../RESEARCH_NOTES.md), [Decisions](../../DECISIONS.md). No implementation plan yet.

## 1. Intent and measure of success

**User-stated:** Hestia's *main identity* is a custom animated character in the **Dynamic Island**, inspired by the feeling of Anima Engine on a Windows desktop. **User-accepted fallback:** occasional character animations are acceptable if continuous looping motion cannot be made reliable on iOS. **Latest product priority:** the character should ideally accompany the user **all day or until the user stops it**; Hestia should not feel like a 25-minute Pomodoro app. This is a user goal, not evidence that iOS can guarantee uninterrupted Island residency. The broader prior brief calls for adopting or importing pet/OC/oshi artwork, local-first use, an inviting lavender/plum design, accessible native behavior, Home Screen widgets and a Lock Screen fallback.

**Revised design assumption requiring review:** **Companion Mode** is the primary experience. A user starts it and Hestia saves their choice **until they press Stop**; this is persistent app state, **not** an indefinitely running background process or continuously visible Dynamic Island. A *separate genuine ongoing task window*, such as "Keep me company while I study/read/create," provides an eligible **finite Live Activity** with a defined beginning and end. The starter target becomes a substantial 4–6-hour window, with possible shorter and up-to-eight-hour choices subject to user testing and App Review considerations. When its system activity ends (at most eight hours from start), Companion Mode remains selected, but **Island presence stops** until the user deliberately starts another legitimate task window. **The user explicitly accepts a one-tap restart approximately every 6–8 hours** rather than requiring uninterrupted residency. iOS can hide the Island earlier. The previously proposed **25-minute focus session is now optional**, not Hestia's central identity. An ambient pet-only Live Activity with no real task is a policy-risk concept, not an approved workaround.

**First-session success hypothesis:** On an eligible iPhone, a new user can choose a supplied original companion, turn on Companion Mode and start a genuine longer task window (initial example: 6-hour creative/study company) within about 60 seconds, without creating an account. They can tell the difference between persistent app selection and time-limited/OS-controlled Island display, know how to stop both, and know how to restart a window after it expires. **The one-minute target applies to the starter-adoption path only; importing/validating a user GIF is a separate measured task.** This is an experiment target, not an achieved metric.

**Principles:** (1) Character before controls; (2) make Island presence worth starting an actual session; (3) preserve truthful native limits; (4) respect privacy, battery and accessibility; (5) one complete journey before editor and social complexity.

## 2. Boundary of Island animation

| Behavior | v1 promise | Reason and fallback |
|---|---|---|
| Smooth imported GIF in foreground app | Planned, subject to decoding/performance verification | Local Image I/O/UIKit playback; reduced-motion/static alternative; **imported GIF frames do not directly animate in Island** |
| Brief expressive motion at a *meaningful* Live Activity content update (a user action or phase change while the app can run) | Planned and limited to Apple's supported content-update transition model; exact visuals require device confirmation | Apple caps data-update animations at two seconds; initial Activity presentation and unattended timed milestones do not guarantee a transition; a static pose always works |
| Idle blink/wave without a state change, repeated every few seconds | **Research only, not promised** | A future bounded device feasibility experiment may demonstrate safe public-API behavior; failing that, use states/one-shot transitions |
| Continuous source GIF/APNG looping in the Island, guaranteed visibility, desktop overlay or 24/7 residency | Explicitly excluded | Live Activities have finite lifetimes; Island visibility is system owned |
| Timer text progressing as time elapses | Planned using native date-driven countdown display | No per-second ActivityKit push, widget timeline or background process |

**Important distinction:** "Occasional animations" means short effects when an allowed state/content change happens or when the user opens Hestia. It does **not** promise the system will wake Hestia to generate blinks at arbitrary moments. Do not add fake data updates, high-frequency timeline entries, perpetual background loops, or a timer/glyph workaround without independent platform feasibility and App Review review.

Official documentation checked October 15, 2026:

- Widget and Live Activity update animations: https://developer.apple.com/documentation/widgetkit/animating-data-updates-in-widgets-and-live-activities
- Live Activity design: https://developer.apple.com/design/human-interface-guidelines/live-activities
- ActivityKit start, update, end, maximum life and payload: https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities
- Dynamic Island layouts: https://developer.apple.com/documentation/widgetkit/dynamicisland

### Duration and renewal options (researched October 15, 2026)

- **Documented:** A standard ActivityKit Live Activity can run up to eight hours, then is automatically ended and removed from Dynamic Island. It may remain on Lock Screen for up to four further hours, but is no longer an active Island character. Apple's Live Activities HIG recommends real tasks/events with a defined start/end. https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities and https://developer.apple.com/design/human-interface-guidelines/live-activities
- **Supported design:** Allow a user to select a genuine longer companion study/reading/focus session, e.g. 1, 2, 4 or 6 hours. A system countdown can show progress, but iOS may hide/preempt the Island sooner. Do not say the character is continuously guaranteed visible for that interval.
- **Possible continuation:** When a real session is complete, the user may actively start another new bounded session. A Control Center control or Shortcut backed by an authorized `LiveActivityIntent` can let the user initiate a new session with fewer steps, including without opening the full app. This is a candidate later convenience feature, not a background restart guarantee. https://developer.apple.com/documentation/appintents/liveactivityintent
- **No reliable "keep it forever" workaround:** Updating the countdown or content, extending an end date, assigning `relevanceScore`, frequent background refreshes, or starting decorative sessions in a loop does **not** reset a Live Activity's eight-hour lifetime or make the Island permanently visible. Push-to-start exists for genuine remotely triggered events, but requires APNs/server infrastructure and cannot be promised to create uninterrupted display. Avoid adding it solely to renew a decorative mascot. https://developer.apple.com/documentation/ActivityKit/starting-and-updating-live-activities-with-activitykit-push-notifications
- **Always-available alternative:** The selected companion remains accessible in-app, and the secondary Home Screen widget keeps a representative still outside timed Live Activities. This is useful after the Island activity expires.

### What "until the user stops" can mean in v1

1. **Companion Mode ON/OFF is persistent:** store the selected companion and an enabled flag. ON survives app termination, relaunch and a Live Activity reaching its eight-hour limit. It does not mean Hestia is executing code continually while closed.
2. **Island has finite display windows:** each must correspond to a real ongoing user task/event with a specified stop/end point (e.g. a work or reading block). Stop Companion Mode ends the current logical task and attempts to end its ActivityKit presentation when Hestia can execute. The HIG expects activity-ending updates at task completion.
3. **After the Activity expires:** no automatic new Island activity, no false "still in Island" status. On next app opening, show Companion Mode still ON and a prominent **"Restart Island session"** single action. Remember the last legitimate task type and duration locally; one tap requests a **new** finite Live Activity with the same settings when the user is actually resuming that activity, without repeating adoption or a multi-step duration picker. If authorization is off, the request fails, or that task has not resumed, show a truthful non-start/recovery state and let the user choose or change the task instead; never imply the Island started. An optional App Shortcut/Control Center control could later reduce the number of taps outside Hestia, but is not required for v1. Opt-in expiry reminders remain a future decision.
4. **Zero-intervention 24/7 display remains unmet:** push-to-start can create a *new* activity for genuine remote events, but requires APNs/server, user/system eligibility, and does not guarantee the Island stays occupied. Synthetic renewal of a decorative pet solely to evade the lifetime cap is not a supported product commitment.

## 3. First-run and continuing journey

1. **Welcome / adopt.** Present one featured original companion and optionally two additional licensed starter choices. Hero character animates in-app when motion is permitted. Primary button: "Choose [companion]." Secondary: "Import artwork." No account screen, full-library photo request or mandatory naming.
2. **Companion home.** Large expressive portrait and short, warm description. Default name can be edited. The primary action becomes **"Start Companion Mode"** (or "Stop Companion Mode" when on), with a secondary **"Start Island session"** prompt to choose a genuine task and window duration. Do not mislabel a mere persistent flag as an active Live Activity. A preview explains: "Your companion stays selected until you stop. During a study, reading or creative session, your buddy can also appear in Dynamic Island for up to eight hours. iOS controls visibility. Your artwork may appear on the Lock Screen." This is not a claim imported GIF frames animate in Island.
3. **Start session.** After Companion Mode is selected, offer a genuine task label (e.g. "Reading together", "Creating together", "Studying together") and a proposed long-duration default of **6 hours**, with shorter windows if useful. Hestia records a separate finite end time at or before the eight-hour ActivityKit ceiling, even though app-level Companion Mode remains ON. Show miniature Island and **Lock Screen** previews with: "Your companion image stays on this phone, but may be visible to others on its Lock Screen while a Live Activity is shown." Explain iOS-controlled visibility. User taps Start while app foreground; request ActivityKit start only if enabled. If Live Activities are switched off, keep Companion Mode ON in app and explain Settings. Without Island hardware, show Lock Screen where supported. For other request failures, give retry/error copy; never imply Island visibility succeeded.
4. **Companion with the user.** On eligible iPhones, Active Live Activity includes a compact character pose + timer, a minimal recognizable character mark, an expanded personality panel when long pressed, and a corresponding Lock Screen presentation. One-shot reactions when Hestia can perform a meaningful update (e.g. user-initiated phase change/manual end) are optional visual enhancements; there is no promise of autonomous milestone or deadline reactions while suspended, nor of a custom animation on initial Activity appearance. Tap system surfaces to return to Hestia for controls. On non-Island phones, Lock Screen Live Activity and in-app companion remain useful.
5. **Manage and finish.** Hestia displays the long task window remaining, current ActivityKit status, **End Island Session** and **Stop Companion Mode** as distinct controls. Ending a task window stops just that finite Live Activity but keeps Companion Mode ON. Stop Companion Mode clears the persistent ON flag, ends any active local task window and requests ActivityKit termination when executable. At an elapsed deadline or system dismissal, Companion Mode stays ON, but the Island presentation is no longer advertised as active; offer **Restart Island session**, prefilled from the last task and duration, with a separate option to change settings. The restart is an explicit, foreground user action and must still meet ActivityKit eligibility. Never imply that selecting Companion Mode alone gives permanent Island residency.

**Continuing use:** Hestia permits **at most one logical active companion session**. A repeated Start while one exists offers Resume or End instead of creating a duplicate. Save a stable local session identifier/start/deadline before requesting ActivityKit; include the identifier in ActivityKit static attributes so a relaunch can match an Activity even if the app was interrupted before saving its returned Activity ID. On return, reconcile the local session's deadline and identifier with Activity.activities / current states: deadline governs logical running-versus-elapsed state, matched ActivityKit state governs whether a system presentation is actually available. End an expired or orphaned Hestia Activity when the app can execute; never fabricate a successful start or silently create a second activity. When records disagree, show a clear recovery state and allow user to end/clear the session. Users can switch companions when there is no active session. **The session uses an immutable poster snapshot stored under its unique session ID:** switching/importing a new companion affects future sessions but cannot overwrite or prematurely delete the image still referenced by this Activity. Retain the poster until the Activity no longer needs it, including possible Lock Screen persistence after end; then clean it up safely.

## 4. Screen and surface specification

### Welcome / companion library

- One beautiful illustrated character above a clear "Choose" action; no busy settings.
- Starter portrait intentionally authored and licensed for Hestia; imported artwork stays private on device.
- If a companion is already selected, bypass onboarding to Companion Home.
- Empty/invalid import never destroys the saved selection; provide "Try again" and "Use starter."

### Companion Home

- Large portrait with expressive in-app animation and a clearly labeled **"Reduce character motion"** preference. It stops Hestia-authored in-app looping and disables Hestia-authored optional system-surface expression effects on future meaningful updates. It cannot prevent all transitions rendered by iOS itself or guarantee instant change to a currently displayed Live Activity. System Reduce Motion and animated-image accessibility preferences also select stable posters.
- Identity: chosen name; one neutral mood descriptor; optional rename.
- Primary action: Start/Stop Companion Mode with a distinct Island session start/renew action. After expiry, display **Restart Island session** as one tap using saved task/duration, rather than requiring repeated task setup; keep an Edit Session option. Secondary navigation: Choose/Import, Surface Preview, Manage Current Session (when active). A shorter focus timer can remain optional, not the identity.
- Distinct preview labels: "Animated in Hestia" and "Dynamic Island: brief reactions during a session; iOS controls appearance." Static Home Screen widget preview clearly labeled "still image."

### Import / personalize

- User-selected PhotosPicker or Files importer; no blanket library permission. Support valid PNG/JPEG/GIF; retain original animated image data when importing GIF instead of accidentally converting through a PNG-only image transfer.
- Inspect actual encoded format, dimensions, frame count/durations and decoded memory cost before storing; reject corrupt, unsupported, decompression-heavy or over-budget files with helpful recovery text. Calibrate concrete size/frame thresholds with representative target-device import experiments before approving this acceptance gate.
- Copy into app-owned storage. Present in-app animated preview for valid GIF and a selected representative still for WidgetKit/ActivityKit. Default uses a deterministic first useful frame; pose-editor cropping is out of v1. **Imported GIFs provide an Island still, not imported GIF frame playback or automatically generated blink/wave/finish poses.** Generic brief appearance/scale/content-change effects on that still may accompany actual supported updates; they cannot imply new facial expressions in unprovided art. Original bundled Hestia starters may include separately authored expression poses. User confirms name and Save before replacing the selected companion.
- If an iCloud-hosted photo is not downloaded, show "That image isn't available offline. Try again when connected, or choose a local file."
- Art is local to the app and shared extension container as required; no upload, public asset catalog or borrowed starter characters.

### Companion Mode and finite Island session in app

- Character and persistent Companion Mode ON/OFF. When a genuine user activity is underway, also show its native countdown, **End Island Session** and a truthful indication of whether Live Activity start succeeded.
- If Live Activities are disabled or revoked, session remains functional in app and offers an actionable Settings explanation. If the device has no Island but supports ActivityKit, continue with a Lock Screen Live Activity. On an unexpected request/runtime failure, show the observed failure and Retry, without suggesting Settings unless authorization is the cause.
- Manual end of a task window keeps the companion selected; Stop Companion Mode also ends the active task window. Avoid extra gameplay, streaks or mandatory notification permissions in v1.

### System presentation matrix

| Surface | Companion | State | Interaction / limits |
|---|---|---|---|
| Dynamic Island compact leading | Small readable companion silhouette/still | One brief pose transition if system permits | No guaranteed continuous motion |
| Dynamic Island compact trailing | Compact remaining-time display | Native timer, still legible at zero | Zero is not proof ActivityKit has ended |
| Dynamic Island minimal | Recognizable companion glyph/portrait or concise timer, prioritized for tiny size | Accessible session identity | Multiple activities can trigger minimal view |
| Dynamic Island expanded | Bigger companion still, name, genuine task label and "Session ends [clock time]" plus time remaining | One-shot state expression when app can perform a meaningful content update | Time-based label stays truthful if the app cannot end the Activity exactly on schedule; tap returns to app |
| Lock Screen Live Activity | Companion still + "[Task] ends at [time]" and countdown | Running / stale / completed only when reflected by an actual available update | Primary fallback when no Dynamic Island; no self-completion by timer text |
| Home Screen widget (secondary) | Selected companion still + name | Selection change requests reload, without a promised exact delay | Useful when no session; no animated GIF playback |

Avoid putting GIF frame data into ActivityAttributes/ContentState. Keep ContentState compact and refer to extension-accessible assets. The system may show no Island card, including when another activity takes precedence, the user dismisses it, or hardware is ineligible.

### States and errors

| Trigger | UI outcome |
|---|---|
| First launch, no companion | Original starter choice, import alternative, no account barrier |
| Permission disabled | In-app timer still available; explain the relevant Live Activities Settings option; no false "Island running" copy |
| Activity request fails for another reason | Explain the failure, offer Retry and in-app continuation; no false activity success or generic Settings advice |
| Non-Island phone | Lock Screen Live Activity when allowed, Home Screen widget and in-app character |
| Session start succeeds | Active state recorded locally and ActivityKit ID tracked |
| System dismisses Live Activity | Persistent Companion Mode remains ON until stopped; underlying task window may continue until deadline, but Island surface is no longer advertised as visible |
| Timer reaches zero while app suspended | Native countdown reaches zero but does not automatically change ContentState, animate a completion or end the Live Activity. The static label states the originally planned end time; on next app execution reconcile elapsed session and end Activity. Companion Mode remains selected and offers Start another. Exact instant system removal is **not guaranteed** without an executing process/remote push |
| Live Activity reaches eight-hour lifetime | iOS ends it and removes it from Island even if Companion Mode remains ON. Hestia cannot automatically guarantee a seamless replacement; next foreground opportunity offers **one-tap Restart Island session** with remembered task/duration if that genuine activity is being resumed |
| Stale ActivityKit state | Show last-known status and reconcile; staleDate/stale state is not the same as automatic completion, a UI phase switch or Activity end |
| App relaunch | Restore chosen companion, compare local session ID/deadline with Activity.activities and reconcile one logical active session; show recovery controls on mismatch |
| ActivityKit end fails while Hestia is running | Stop the logical in-app timer, mark system end **pending**, display truthful status and retry on a subsequent app execution; do not claim the Island disappeared |
| Import rejected / App Group unavailable | Keep saved companion; explain error and offer retry. No silent unrelated storage fallback |
| Reduce Motion / animated-image playback disabled | Static friendly pose, same information and controls |

## 5. Visual and accessibility system

- Warm lavender/plum, cream/off-white surfaces, accessible contrast, restrained rounded rectangles and small cozy visual details. Use system Dynamic Type text styles and SF Symbols where suitable; avoid absolute-size text and tiny controls.
- Original character illustrations are the primary visual focus. Build no proprietary rendering framework before a native proof. Bundled originals can supply authored poses for **idle (in app)**, **starting**, **focusing**, **celebrating/finished**, **still fallback**. Each state has a stable readable image. For user-imported art, a chosen still/representative frame is sufficient for all Island states; Hestia must never promise to synthesize new expressions from one GIF or still.
- Animation is celebratory and restrained (roughly sub-two-second content-update effects); no flashing, frantic jumping or battery-expensive frame dispatch. Test dark/light, always-on and tinted widget states.
- VoiceOver reads character name, session status and countdown meaningfully. Decorative repeated images should not create redundant announcements. End Session is accessible at large text sizes and clear without color alone.
- Reduce Motion and accessibilityPlayAnimatedImages are respected; still art communicates the same state. Provide an in-app "Reduce character motion" preference even without system preferences; it applies to Hestia's in-app playback and Hestia-authored brief system-surface effects when the Activity is next actually updated. Do not claim this overrides iOS-owned presentation transitions.
- Clearly distinguish **local storage** ("Your artwork stays on this phone") from **physical visibility** ("Your companion image can appear on the Lock Screen during a session"). Show the Lock Screen image before session start; no requirement for cloud sharing or broad media permission.

## 6. Proposed minimal technical arrangement (no code changes authorized)

Use the starter's SwiftUI, WidgetKit and ActivityKit patterns **if the real starter is recovered and validated**. If not recovered, a replacement project requires its own approved plan. Target iOS 17 remains a historical assumption to verify against current APIs and users' devices.

**Logical responsibilities, not required new modules:**

- **Local companion selection:** one selected companion ID, name, local art references and safe poster. Store preferences and shared still-art within an entitled App Group used by the app and widget extension. **Freeze a separate session poster file for each Activity ID/session UUID and retain it until no Activity presentation can reference it.** Subsequent imports/selection changes affect the next session without replacing in-use art. No cloud or account. Never silently fall back to an unrelated store when the shared container fails.
- **In-app art presentation:** native Image I/O/UIKit decode for GIF frames, SwiftUI integration, bounded resource use, frame timing and Reduce Motion. Static PNG/JPEG support.
- **Companion preference and Live session coordinator:** Persist a separate **Companion Mode enabled flag** that is user-owned and indefinite as *data*, without creating a background process. Independently manage at most one finite **genuine task** window through ActivityKit authorization, request/update/end/reconcile plus a stable UUID, start/deadline, phase and optional Activity ID. Include the UUID in static ActivityKit attributes for crash recovery. Prevent duplicate active task windows; distinguish Companion Mode ON from ActivityKit available/active. Model window phases **starting, running, elapsed, end-pending, finished** and separately observe ActivityKit **active, stale, ended, dismissed or missing**. Deadline governs elapsed logic; a failed end remains end-pending and is retried when executable. At expiry user may explicitly start a fresh task window. No remote push/backend or guaranteed automated renewal. Use native date-driven timer for the window, not per-second background updates; do not promise Activity end executes while suspended.
- **Widget extension:** WidgetKit Home Screen static selected art and ActivityConfiguration for Lock Screen/Island compact/minimal/expanded views. Small ContentState (session phase, deadline, companion reference); keep full image files out of ActivityKit payload, which is limited to 4 KB total static/dynamic data.

**Data/control flow:**

Select or safely import art → validate and store local companion/selected ID → user turns Companion Mode ON (persisted) → derive static poster in shared App Group → request widget reload → user chooses real ongoing task and a bounded multi-hour Island window → reject/resolve existing task window → save new session UUID + deadline → check authorization and request ActivityKit with session ID, companion reference and deadline → ActivityKit surfaces show task label, native countdown and stable character pose, with short transitions only on meaningful executable updates → window ends by user choice or app reconciliation, while Companion Mode stays ON → offer explicit fresh task window if wanted → user can separately Stop Companion Mode, which also ends an active window.

**No speculative dependencies:** no animation SDK, custom game engine, arbitrary background service, remote push provider, account or App Intents configuration widget until required by an approved acceptance test.

## 7. Acceptance criteria, validation and milestone dependency

These acceptance criteria belong to the **user-approved written design**. They remain planned behaviors and are not verified implementations.

1. Given first launch on a supported iPhone, choosing an original starter, enabling Companion Mode and initiating an honest multi-hour task session takes at most ~60 seconds in a small observed first-use study; no registration required.
2. Given imported valid PNG/JPEG/GIF artwork, Hestia correctly displays it in-app, retains the chosen companion across relaunch, plays GIF when animation is enabled, and renders a representative still on system surfaces **without implying imported animation plays in the Island**; invalid/oversized inputs show recovery without erasing the old companion.
3. Given an eligible Dynamic Island iPhone and Live Activities enabled, start displays appropriate compact/minimal/expanded/Lock Screen content as the system allows. The pet and countdown are recognizable; any one-shot transition does not exceed supported animation limits.
4. Given a supported iPhone without Island hardware, authorized sessions remain useful in Lock Screen Live Activity and in app.
5. Given Live Activities disabled/request failure, the in-app timer starts or continues with clear truthful text, and no false activity success status.
6. Given manual end, activity reconciliation after relaunch, user dismissal or an elapsed deadline, in-app state and activity tracking converge without duplicate or endlessly stale sessions. Repeated Start never creates a second logical session. Simulate interruption between ActivityKit request and ID persistence, mismatched/orphaned activity states and a failed end; verify stable-ID recovery and retry. If app is suspended, no assertion of exact-second system removal, autonomous completion expression or automatic ContentState change.
7. Given VoiceOver, extra-large Dynamic Type, Reduce Motion/disabled animated images, dark/light appearance and Always-On conditions, character state and timer remain perceivable, controls usable, and quiet still fallback available.
8. Given restart or storage error, shared companion selection consistency is checked in the App Group; no silent fallback to unrelated user data.
9. Given off-network conditions, normal starter selection and local session handling still work. An unavailable iCloud-only import offers retry without blocking the app.
10. Device and release validation must include current iOS on at least one Island iPhone and one without Island, signed App Group/widget-extension build, actual import/GIF performance, app restart, system dismissal, accessibility, battery behavior, copyright and App Review checks.
11. Given a companion switch/import while a Live Activity still references existing artwork, its session-specific poster remains intact through Lock Screen display/dismissal, then can be reclaimed safely; imported personal art visibility on the Lock Screen was disclosed before Start.
12. Given the user enables Companion Mode, its ON selection survives app restarts and a finite ActivityKit window ending; **it never claims that the Island remains visible after that window**. User-initiated Stop turns off mode and requests termination of any active task window. When a window expires, the user can intentionally **restart a genuine bounded session in one tap inside Hestia**, reusing the previous task type/duration without re-importing, re-adopting or revisiting a setup form. Verify an explicit ActivityKit request, permission/failure recovery, eight-hour maximum and competing-activity preemption on real devices. Native Shortcuts/Control Center renewal is a possible later enhancement, not a hidden dependence of the acceptance test.

**Outcome-based build order after future plan approval:** (1) starter → local selection → real Island/Lock Screen timed session with static pose and truthful controls (main vertical slice); (2) short allowed character transitions and lifecycle hardening; (3) safe import + animated app preview + shared poster; (4) secondary Home Screen widget and polish. Move any item earlier only if the recovered starter reveals validated dependencies. Do not interpret this sequencing as an implementation plan or as permission to work.

**Key risks / feasibility checks before committing to more motion:** signed Live Activity layouts on current Island and non-Island iPhones; exact behavior of update transitions, Always-On and reduced motion; no per-frame background work; whether imported artwork is readable in the extension and held for its full Activity lifetime; session state after suspension; energy/thermal usage. **A perpetual decorative pet alone may not meet Apple's Live Activity HIG expectation of a genuine ongoing task/event with defined start/end.** Real reading/study/creative sessions must provide truthful task/status information; even this does **not guarantee App Review approval**. Test whether people would genuinely use this framing. Optional idle blink research is a separate explicitly approved spike, and failure leaves the baseline product valid.

## 8. Explicit exclusions and next approval

**Excluded from v1:** always-on decorative Island overlay; infinite Island GIF loops; guaranteed persistent Island visibility; custom animation authoring, sprite editor, AI generation, cloud sync, uploads/public social feeds, subscriptions, notifications, remote ActivityKit pushes, unrelated timers and gamification. Starter art must be Hestia-original or appropriately licensed. Imported fan art remains local and under the user's rights.

**Resolved direction and written-design approval:** The user **accepted one-tap, user-initiated renewal roughly every 6–8 hours**, with Companion Mode remaining ON until explicitly stopped, then explicitly replied **"I approve"** to the request for approval of the revised full written design. There is no requirement for uninterrupted 24/7 Island residency. The accepted task framing is genuine reading/study/creating windows rather than decorative timers invented to evade the eight-hour limit. This does **not** approve an implementation plan, specific scaffold or source changes.

**Next gate:** After this written-design approval, prepare evidence-backed gap analysis and a Superpowers implementation plan and request **separate explicit plan approval** before touching application code. The selected Windows folder has no iOS starter or Git repository; a Mac/Xcode and eligible iPhone are required for native verification. No claim of App Store readiness.
