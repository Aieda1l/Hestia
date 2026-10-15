# Hestia decisions — append-only log

## 2026-10-15 — User direction: Island character is Hestia's identity

**Status: User-stated product priority; recorded, not a complete design approval.** User said: "I want the dynamic island animated character to be the main identity. It should be inspired by Anima Engine, but for iOS." This supersedes the research-stage suggestion that the Home Screen widget be the signature surface.

**Rationale:** The product's key emotional value is expressive personal presence near the iPhone's front camera area. User adoption/import and widgets support that identity.

**Limitations:** ActivityKit controls Live Activity lifecycle; Apple/system controls Island eligibility, layout and visibility. No permanent decorative overlay can be promised.

## 2026-10-15 — User accepts occasional motion as fallback

**Status: User-stated animation requirement, accepted at direction level.** User said: "Occasional animations are fine if continuous looping motion isn't possible."

**Interpretation:** Preserve a lively expressive Island character through short state-driven transitions when supported; full continuous GIF playback belongs in-app. Verify additional idle motion only through a separate platform experiment. Never represent the optional experiment as current capability.

**Next approval:** Written Island-first design at [canonical spec](superpowers/specs/2026-10-15-island-first-companion-design.md), including a time-bounded focus session as a proposed use case, requires explicit user review before implementation planning.

## 2026-10-15 — User priority: ideally all day or until explicitly stopped

**Status: User-stated intent, not Apple-supported Island behavior or written-spec approval.** Asked about duration after learning 25 minutes was just a design choice, user replied: "Ideally all day or until the user stops it."

**Interpretation:** An all-day pet companion is the product emotional goal, not a timer-centered Pomodoro app. Supersedes treating 25-minute focus as the main action. Proposed separation: persistent local Companion Mode ON until user presses Stop, plus finite Live Activity windows associated with genuine ongoing tasks. Apple documents a maximum of eight hours per Live Activity and can hide/dismiss it earlier; the selected companion survives but the Island display cannot be promised for all day. User may start another real activity later; no undocumented background renewal scheme.

**This tradeoff was subsequently resolved:** user accepts one-tap renewal roughly every 6–8 hours, rather than demanding uninterrupted Island residency. See the following decision. User must still review the entire revised written spec before any implementation plan.

## 2026-10-15 — One-tap Island renewal is acceptable

**Status: User-approved product compromise, not approval of the full written spec.** User said: "One tap restart would be fine."

**Decision:** Companion Mode persists locally until Stop. The user is comfortable manually starting another authentic, bounded Live Activity after the system window ends. **The proposed v1 experience gives one-tap restart inside Hestia using the previous task/duration**, with an option to change task and with truthful denial/errors. Optional Shortcuts/Control Center/notifications may improve discovery later but are not needed for this compromise. A single activity still ends by Apple's lifecycle limits; iOS visibility remains discretionary. No auto-renewal hacks or promise of permanent Island appearance.

## 2026-10-15 — Written Island-first design approved

**Status: Explicit design approval; Stage C planning authorized, app implementation NOT authorized.** After the revised canonical design was presented with the specific question "Do you approve the revised Hestia design so we can move to the implementation-planning stage?", the user responded: "I approve."

**Approved source:** [Island-first companion design](superpowers/specs/2026-10-15-island-first-companion-design.md). This includes persistent Companion Mode, a genuine finite reading/study/creative window of up to eight hours, one-tap user-initiated restart, character-first UX, optional brief Island transitions, real GIF playback only in app, safe import, secondary snapshot widget, accessible non-Island/denied fallbacks, and honest lifecycle/privacy limitations.

**Next independent approval gate:** Evidence-based gap analysis and concrete implementation plan(s), which must be reviewed/approved separately before production code, scaffolding, dependencies or Xcode project changes. Previous discussions did not approve replacing the absent earlier SwiftUI starter without an explicit plan.

## 2026-10-15 — Both implementation plans approved for execution

**Status: Explicit execution approval, subject to the approved plan's technical test gates.** After presentation of the two plans, including the missing SwiftUI starter, replacement scaffold proposal, Xcode/device blocker, and recommended subagent reviews, the user stated: "I approve. Please proceed."

**Approved work:** [Core Island companion implementation plan](superpowers/plans/2026-10-15-island-companion-core.md) followed by the dependent [Artwork/GIF and snapshot widget plan](superpowers/plans/2026-10-15-companion-art-and-widget.md). Implementer may create a **minimal scaffold in the chosen Hestia folder** after a source recheck; the plan requires a Mac/Xcode native compile/simulator gate before continuing to substantial uncompiled Swift feature implementation.

**Environment ruling:** Hestia is not a Git repo and the Windows host has no xcodebuild/xcodegen/Swift. Do not initialize Git, fake compilation, assume App Store eligibility, or overwrite recovered starter. Keep Task 1 scaffold review as file-level evidence and stop at the documented native gate.

## 2026-10-15 — Windows development with private GitHub macOS CI

**Status:** Execution continuation authorized by user: "I have an iPhone 16 Pro. Please proceed." Context was the proposed Windows → private GitHub repository → GitHub-hosted macOS Xcode generation/build/test → eventual signed device installation path.

**Decision:** Initialize local Git in the selected Hestia workspace, create and push to the private `Aieda1l/Hestia` repository using existing authenticated GitHub CLI, and run unsigned iOS simulator smoke CI on `macos-15` with no Apple signing credentials. This replaces the previously blocked Windows-only compiler gate with a real external native build runner; physical iPhone testing remains a separate signing/provisioning step. No user-selected artwork or signing secrets are committed.

**Observed first run:** `38815590398` generated the Xcode project and built app plus extension successfully; XCTest result was pending at the time of this entry. No App Store/TestFlight app exists yet. The prior prohibition on creating a Git repository was a **pre-approval state**, superseded by the user's explicit request to proceed with the GitHub cloud-build workflow.
