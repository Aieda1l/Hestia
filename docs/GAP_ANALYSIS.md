# Hestia — approved-design vs observed-source gap analysis

**Checked:** 2026-10-15, `/projects/Hestia`, with a read-only search for likely starter filenames under parent `/projects`.
**Reference:** [approved written spec](superpowers/specs/2026-10-15-island-first-companion-design.md).
**Status:** Stage C planning evidence, **not an implementation or functional test**.

## Source inspection evidence

The checked working folder is on **Windows NT 10.0.26200.0**, mapped to `D:\cyrus\OneDrive\Projects\Hestia`. It contains `AGENTS.md`, `SKILLS_MANIFEST.md`, `.agents/skills/` and project docs. No Swift code, Xcode project, XcodeGen `project.yml`, images, entitlements, unit/UI tests, app bundle or `README.md` was present. This is **absence in the selected checkout**, not proof a prior Hestia app never existed.

Executed read-only commands through CoS PowerShell:

- `Get-ChildItem -LiteralPath . -Recurse -File -Force`, filtering the unrelated skills subtree from printed output: instructions and docs only.
- `rg --files .. -g project.yml -g HestiaModels.swift -g HestiaWidgets.swift -g '*.xcodeproj/project.pbxproj' -g Package.swift -g 'Hestia*.swift'`: **no matches** (exit 1). Checked accessible nearby projects, not every disk or cloud backup.
- `git rev-parse --show-toplevel`: **fatal: not a git repository** (exit 128); no current Hestia Git baseline.
- `Get-Command xcodebuild,xcodegen,swift,swiftc,git,rg`: **git and rg found**, Apple/Xcode tools **not found** in PATH. No native source/build/test target here.

## Evidence-based gaps

| Approved requirement | Observed baseline | Consequence / proposed delivery | Evidence needed to close |
|---|---|---|---|
| Native app and extension project + signed App Group | No project, entitlements or Swift targets | Recover original source/reconcile plan, or after explicit plan approval scaffold app/WidgetKit extension/tests | Generated project builds/signed in Xcode |
| Starter pet and Companion Mode ON until Stop | No assets, store or UI | Original simple vector mascot, persisted selected character/flag | Unit tests + simulator first-use |
| Real bounded task and Dynamic Island / Lock Screen | No ActivityAttributes, coordinator, extension | Model + state machine + native ActivityKit bridge and layouts | XCTest, simulator and Island hardware |
| One-tap restart after about 6–8 hours | No activity/session state | Remember task/duration; user tap starts new activity, not an automatic one | Deterministic tests + device restart |
| Duplicate prevention and crash/stale/end handling | No reconciliation code | Single logical UUID, local deadline and Activity.activities reconciliation | Adapter tests and relaunch/dismissal |
| Permission and non-Island fallback | No app/extension | Explicit disabled/failure states, in-app countdown and Lock Screen view | Fake client + non-Island iPhone |
| User-selected PNG/JPEG/GIF import | No files/importer/decoder | Photos/Files picker, Image I/O, resource bounds, stable poster | Fixture, memory and device tests |
| Secondary Home Screen widget | No WidgetKit target/shared container | Static poster App Group, widget timeline and truthful manual preview | Signed widget and refresh behavior |
| Accessibility/privacy/art rights | No UI/approved artwork assets | Native labels, Reduce Motion, Lock Screen art disclosure, original starter | Device/accessibility/asset review |
| Build, simulator, signing and device matrix | No Mac/Xcode | Required external verification checkpoint | Mac build and current signed phones |

## Scope and source-recovery rule

1. **Before implementation**, recheck for the original starter. If present, inspect actual source/entitlements/paths/tests/Git and reconcile the plan; **do not overwrite it**. If absent, a new scaffold is a **proposed choice in the implementation plan requiring separate user approval**.
2. No old app code was inspected/restored. This is **not** a regression analysis, and no working feature is verified. Apple documentation alone cannot prove native widget/Island behavior.
3. Two sequential, reviewable deliverables are planned: **original starter → persistent Companion Mode → genuine ActivityKit window → one-tap renewal**; then **PNG/JPEG/GIF import and snapshot widget** on those tested interfaces.
4. No source-control initialization, signing-team assumption, release or background renewal is authorized by writing this gap analysis.

## Planned files

- [Core Island implementation plan](superpowers/plans/2026-10-15-island-companion-core.md)
- [Art import and Home Screen widget plan](superpowers/plans/2026-10-15-companion-art-and-widget.md)
- [Verification gates](TEST_PLAN.md)

**Update, 2026-10-15:** Both implementation plans were subsequently approved. The core Task 1 **minimal XcodeGen scaffold now exists** with app and extension @main sources, shared original starter mascot, both App Group entitlement files, separate unit/UI smoke-test sources and a Mac test script. This partially addresses the *source-absence* row above, but **does not close the native-build or feature gaps**. Windows-only static YAML, plist and shell syntax checks passed. Invoking the script returned exit code 2, `BLOCKED: xcrun is required on a Mac with Xcode installed`. Treat the table as the original pre-scaffold baseline, not a live claim that `project.yml` is still missing. No working ActivityKit, artwork import, persistence or WidgetKit snapshot feature has been verified.
