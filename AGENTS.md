# AGENTS.md — Hestia engineering operating contract

## 1. Mission and scope

**Hestia** is an iPhone-first companion app for personalized pets, original characters, and fan-created “oshis.” Users should be able to choose or import a companion, see expressive animation **inside the app**, and display a meaningful representation of their companion in supported iOS widgets and **time-bounded** Live Activities, including Dynamic Island on eligible devices.

This file applies to any coding assistant or delegated worker operating in the Hestia repository. It is a repository contract, not a subscription, provider, tooling, or model configuration. Follow higher-priority user instructions and the actual capabilities/permissions of the current environment.

**Mission:** Deliver the smallest correct, delightful, and verifiable user-facing increment, while leaving a maintainable native iOS codebase and a reliable record of what has been decided, tested, and deferred.

The main working session is the **orchestrator**: it owns intent, prioritization, integration, approvals, and durable project state. It may delegate bounded, independent work when workers are available and permitted; delegation is an optimization, not a prerequisite.

## 2. Product compass

- **Audience:** iPhone users who want a friendly custom pet/character or a personal oshi companion without complex setup.
- **Core journey:** open Hestia → choose/adopt or import artwork → personalize → preview eligible surfaces → add a widget or start a companion session → see clear results and controls.
- **Design character:** cozy, gentle, playful, accessible, uncluttered. Warm lavender/plum/pastel styling is a *starting direction*, not an excuse to ignore native iOS patterns or user feedback.
- **Trust promise:** accurately explain what is animated, what is a snapshot, where a companion can appear, and how long a Live Activity lasts.
- **MVP posture:** local-first, no account required, avoid a backend, subscriptions, social feeds, AI generation, or complex sprite authoring without a validated current requirement.
- **Inspiration:** Anima Engine is a *conceptual reference*, not a specification to duplicate or a source of licensed characters/assets. Respect third-party IP, fan art rights, and attribution.

### Native-platform truth is a product requirement

1. A Dynamic Island presentation is part of a **Live Activity**, not an unconstrained always-on floating overlay. Design around a genuine ongoing, time-bounded purpose (e.g., focus/study/reading companion session); never promise indefinite decorative Island residency or guaranteed visibility.
2. **In-app** imported GIF/sprite animation and **system surfaces** require different rendering strategies. Widgets use WidgetKit timelines/snapshots and system-controlled refreshes; Live Activities use ActivityKit state and system-managed transitions. Neither is a continuously running GIF canvas. Apple's current documentation describes a maximum of two seconds for widget/Live Activity data-update animations; confirm the exact behavior for the deployment target.
3. Support Dynamic Island compact/minimal/expanded layouts **only where hardware supports them**, alongside a useful Lock Screen Live Activity fallback. Treat permission denial, session expiry, absent Island hardware, and system dismissal as normal states.
4. Implement accessibly: Dynamic Type, VoiceOver labels, sufficient contrast, Reduce Motion, tappable controls, and understandable empty/error states. Avoid draining battery or driving excessive timeline reloads.
5. Investigate App Review guidelines and feature eligibility before presenting anything as App Store ready. Record official references and verification dates for relevant claims.

## 3. Existing repository: inspect, do not assume

An earlier Hestia SwiftUI starter includes:

- `project.yml` — XcodeGen specification; currently targets iOS 17.0.
- `App/` — SwiftUI views, a companion store, local GIF animation, ActivityKit session management.
- `Shared/HestiaModels.swift` — companion model, shared App Group configuration, Live Activity attributes.
- `Widget/HestiaWidgets.swift` — WidgetKit and Live Activity/Dynamic Island presentation.
- `README.md` — setup instructions and explicitly unverified limitations.

**Treat this as an unverified starting point.** An earlier starter was not compiled in Xcode or tested on physical hardware. Inspect the *actual* checkout: files may have changed or may not be present. Verify XcodeGen outputs, Info.plist generation, Swift compilation, entitlements, App Groups, extension embedding, ActivityKit behavior, image handling, and all claims before building on it. The absence of Xcode or hardware is a test blocker, not proof that a feature works.

## 4. Three complementary workflow systems

Use what is **actually installed and authorized**, after discovering its current commands and skill instructions. Avoid duplicate or competing process layers.

| System | Primary responsibility | Use in Hestia |
|---|---|---|
| **CoS (Chat on Steroids)** | Approved local workspace/terminal access, bounded parallel workers, checkpoints/continuity | Inspect/edit files, run real commands, delegate independent tasks, persist findings before context resets. Respect workspace permissions and provider limits. |
| **Superpowers** | Research-informed brainstorming, specification approval, planning, TDD, systematic debugging, reviews, verification | Use its relevant installed skill instructions for creative/product/architectural changes; honor explicit approval gates. |
| **ECC (Everything Claude Code)** | Selective skill/rule/tooling support for quality, security, research, and engineering | Load only relevant common/Swift/iOS/security/test guidance. Avoid redundant agents, hook conflicts, or rules intended for a different stack. |

**Precedence when they overlap:** user-approved requirements and `AGENTS.md` define *what* and the evidence threshold; the relevant Superpowers skill defines *how* to run its workflow; ECC provides focused engineering guidance; CoS supplies the execution environment. If instructions conflict, pause and report the concrete conflict rather than silently ignoring an approval/safety requirement.

Web research and other reference lookups are allowed **when available and useful**, but are not a mandatory execution route. Local Apple SDK documentation, repository sources, and supplied PDFs are valid inputs. Never fabricate a source, command result, permission, or test outcome.

## 5. Non-negotiable engineering rules

1. **Research before guessing; brainstorm before substantial new behavior.** Start a new feature/architecture effort by inspecting the actual repo, examining platform limits, and exploring alternatives with the user. No implementation before the applicable design approvals.
2. **MVP before ambition.** One thin end-to-end journey beats disconnected polish and speculative infrastructure.
3. **YAGNI.** Choose the minimum modules, packages, stores, protocols, workers, abstractions, and services required by current acceptance criteria.
4. **Evidence over claims.** Never say “built,” “working,” “tested,” or “App Store ready” without the relevant observed result.
5. **Durable truth lives in repository docs**, not an ephemeral conversation or delegated worker state.
6. **Keep approval independent of implementation.** Do not let an implementer be the sole reviewer/verifier of its own work; when no independent worker is available, request a human review or transparently report reduced assurance.
7. **Protect user work.** Inspect `git status`, preserve unrelated changes, ask before destructive file/branch operations or external publishing.
8. **Use local-first data practices.** Import only user-selected files, validate formats/sizes, store safely, avoid leaking photos/assets/logs or treating imported art as available to third parties.
9. **No false platform capabilities.** Use Apple-supported APIs and documented lifecycle constraints; never design around unsupported persistent background loops or overlay hacks.
10. **Never invent verification commands.** Discover them from the repo and toolchain, then record exact invocations and outcomes.
11. **Keep scope visible.** Put speculative enhancements in `docs/BACKLOG.md`, not inside an accepted milestone.
12. **Ship understandable UI.** Empty states, error recovery, accessibility, and clear onboarding are functional acceptance criteria.

## 6. Durable documentation and ownership

Create missing docs **as they become relevant**; never create empty boilerplate just to satisfy a list. Reconcile docs against source code and test results.

- `docs/PRODUCT_BRIEF.md` — audience, problem, outcomes, product principles, non-goals.
- `docs/RESEARCH_NOTES.md` — dated verified findings, citations/URLs, confidence, unresolved questions.
- `docs/IOS_CAPABILITY_MATRIX.md` — app/widget/Lock Screen/Island capabilities, restrictions, fallbacks, device and OS behavior.
- `docs/MVP_SCOPE.md` — explicit in/out boundary and measurable journey acceptance criteria.
- `docs/GAP_ANALYSIS.md` — current behavior vs required behavior, supported by file/test evidence.
- `docs/ARCHITECTURE.md` — **implemented** modules, storage, updates, data flow, security boundaries; separately label approved planned work.
- `docs/UX_SPEC.md` — first-use flow, screens, interaction states, copy, accessibility, surface previews.
- `docs/ROADMAP.md` — ordered, outcome-driven milestones.
- `docs/TEST_PLAN.md` — unit, UI, integration, simulator, device, accessibility, performance, release checks.
- `docs/DECISIONS.md` — append-only architecture/product decision log, with rationale and alternatives.
- `docs/BACKLOG.md` — deferred/nonbinding feature ideas.
- `docs/PROJECT_STATE.md` — compact current checkpoint: status, verified evidence, blockers, next action.
- `docs/plans/active/` and `docs/plans/completed/` — actionable plans and their history; if an installed skill requires a different canonical spec/plan location, use that and cross-link rather than duplicate.

`docs/PROJECT_STATE.md` must never claim that a check passed based on an old environment, an unrun command, or a delegated assertion without evidence.

## 7. Session start / resumption

Before editing production code:

1. Read `AGENTS.md` and relevant instructions for installed skills; locate `docs/PROJECT_STATE.md`, `docs/MVP_SCOPE.md`, and any active plan, if they exist.
2. Inspect `git status`, the last relevant commits, and the smallest set of source files required to understand the task.
3. Discover toolchain and actual project commands (`xcodebuild`, `xcodegen`, test schemes, lint tools) rather than assuming availability; note the host OS.
4. Read the product and capability docs for work affecting widget/Live Activity behavior or artwork import.
5. Identify whether the task needs a brainstorming gate, a small investigation spike, or is an obvious mechanical fix.
6. Before extended implementation, write the next action and existing blockers to `docs/PROJECT_STATE.md`.

On resumed/compacted CoS sessions, restore truth from repo docs and observed `git` state, **not** an assumed worker recollection.

## 8. Project workflow and approval gates

### Stage A — Research + brainstorming (required at project kickoff)

- Inspect the starter, relevant Apple docs/SDK availability, user experience goal, and UI component sources (`https://componentskit.dev/`, `https://nibware.dev/`) if accessible; verify reuse terms before copying code.
- Examine competing design approaches, platform feasibility, image/animation strategy, privacy/IP, accessibility, and an easy 1-minute onboarding flow.
- Categorize every user-facing behavior as **verified feasible**, **feasible with limitations**, **unknown / needs spike**, or **not supported**, with evidence and fallback.
- Present 2–3 coherent product/architecture alternatives with a recommended MVP, explicit compromises, and ONE high-value question at a time when the answer affects direction.
- Use the currently installed Superpowers `brainstorming` workflow where present. Observe its design approval gates before implementation, even if doing so requires stopping and waiting for the user.

### Stage B — Approve scope/design before implementation

- Obtain agreement on the target user journey, platform truth, accessibility promises, and what the MVP excludes.
- For architectural work, produce the written spec in the location required by the active brainstorming skill, self-review it, and request explicit user approval of the written artifact.
- Update `PRODUCT_BRIEF.md`, `MVP_SCOPE.md`, `UX_SPEC.md`, `IOS_CAPABILITY_MATRIX.md`, and decision log appropriately. Plans are not permission to exceed approved scope.

### Stage C — Gap analysis and executable plan

- Verify what already exists in code. Compare the approved journey against the implementation and tests.
- Use the installed `writing-plans` skill for nontrivial approved work. Write short, ordered, independently verifiable tasks with paths, acceptance criteria, exact tests/commands, safe parallelism, and explicit file ownership.
- Request plan approval where the active skill requires it. Keep a single active plan or explicitly name concurrent non-overlapping plans.

### Stage D — Small implementation increments

- Delegate independent, scoped tasks if CoS workers are available; otherwise work sequentially.
- Implement testable behavior with **RED → GREEN → REFACTOR**; use a practical investigation spike for framework behavior that cannot be unit tested initially.
- Prefer SwiftUI/WidgetKit/ActivityKit and platform SDK APIs; add third-party components only after license, deployment-target, accessibility, and maintenance checks.
- Preserve file privacy/extension constraints (shared App Group assets, secure import, asset decoding, graceful fallback).
- Run targeted checks after every task; report file changes, exact observed results, and unknowns.

### Stage E — Independent review and verification

1. **Spec review:** is the required user journey present, without unapproved extras?
2. **Quality review:** failures, concurrency/state restoration, extension storage, permissions, stale sessions, input validity, accessibility, energy use, security, and maintainability.
3. **Verification:** reproduce a failing case before a fix where possible; run task-focused checks, full relevant tests, build and smoke tests, plus on-device validation for Island claims.
4. Fix only documented findings; rerun affected reviews/tests. Do not replace verification with screenshots of a web mockup.

### Stage F — Checkpoint and next milestone

- Update `PROJECT_STATE.md`, `GAP_ANALYSIS.md`, `TEST_PLAN.md`, and `DECISIONS.md`; update `ARCHITECTURE.md` only to reflect implementation actually present.
- Move a plan to completed only when its acceptance criteria and verification are satisfied.
- Continue only within approved scope. Stop at a consequential user decision, authorization need, destructive action, or unresolved critical check.

## 9. Delegation contract

Every delegated task should carry **Role · Goal · Why · Read · Constraints · Files owned · Acceptance · Verify · Return**. Provide narrow context and exact references; avoid forwarding an entire chat. Choose from:

- **Explorer:** read-only repository, platform, dependency, or UX feasibility investigation.
- **Planner:** plans/specs only after the relevant approval; no production changes.
- **Implementer:** small scoped code and tests, owns disjoint files, no self-approval.
- **Spec reviewer:** read-only match against approved requirements.
- **Quality/security reviewer:** read-only correctness, privacy, accessibility, extension lifecycle, hazards.
- **Verifier:** executes real commands/smoke tests and reports logs/results; does not fix code unless reassigned.

Parallelize only when independently productive and permitted. Coordinate edits to `project.yml`, shared models, entitlement files, and the widget extension; they are frequent merge-conflict and configuration hotspots. Do not recursively spawn workers without a clear rationale and explicit capability.

## 10. Hestia-specific acceptance and testing priorities

The MVP cannot pass based on visual appearance alone. Verify at minimum:

- First launch: understandable library, starter selection, permission explanation, and path to a visible companion.
- Asset imports: valid PNG/JPEG/GIF from user-selected sources; clean rejection of unsupported/corrupt/oversized files; animation plays **inside app**; static fallback is clear on system surfaces.
- Persistence: companions and the selected companion survive app relaunch; widget extension reads the intended App Group without silently switching to unrelated storage.
- Widget: correct artwork or fallback, appropriate layout, reload behavior, states without activity, accessible label and legible appearance.
- Live Activity: authorized start/update/end, countdown and expiry, restoration after app restart, error/permission handling; **compact, minimal, expanded, and Lock Screen** presentations.
- iPhone without Dynamic Island: the app still works, with Lock Screen Live Activity/widget support as applicable.
- Accessibility and robustness: VoiceOver, Dynamic Type, Reduce Motion, dark/light/Always-On considerations, disk limits, app-group failure, activity dismissal, low connectivity (no required backend).
- Xcode build and device behavior: distinguish parse-only validation, simulator build, simulator interactions, and real-device verification; document each separately.

Do not claim App Store readiness until code signing, release entitlements, asset rights, privacy disclosures, accessibility, performance, device matrix, and Apple review requirements have been examined.

## 11. Simplicity gate

Before adding a dependency, service, new storage layer, generic abstraction, permissions request, widget kind, or background mechanism, answer:

1. Which **approved, current acceptance criterion** requires it?
2. What direct/native solution is simpler?
3. What concrete failure will happen **now** without it?

If uncertain, start with a small evidence-gathering spike or put the idea in `BACKLOG.md`. Keep copyright/licensing and OS correctness non-negotiable.

## 12. Completion/reporting standard

A milestone is complete only when: requirements match the implementation, independent spec and quality review findings are resolved or explicitly accepted, applicable test/build/device gates have concrete evidence, docs match reality, and `PROJECT_STATE.md` identifies the next action. When a necessary check cannot run, say **“not verified in this environment”** and name the exact external check still required.

Report concisely in this format:

- **Outcome:** what the user can now do (or what was researched/approved).
- **Evidence:** exact commands, results, simulator/device context, and affected paths.
- **Limitations:** observed failures, blockers, and untested environments.
- **Next action:** one smallest approved step or one decision required from the user.

## References for project research

- Apple: [Live Activities HIG](https://developer.apple.com/design/human-interface-guidelines/live-activities), [ActivityKit](https://developer.apple.com/documentation/activitykit), [WidgetKit](https://developer.apple.com/documentation/widgetkit), [widget/Live Activity animations](https://developer.apple.com/documentation/widgetkit/animating-data-updates-in-widgets-and-live-activities).
- CoS: https://github.com/totec448-spec/chat-on-steroids
- Superpowers: https://github.com/obra/superpowers
- ECC: https://github.com/affaan-m/ECC
- Optional UI references: https://componentskit.dev/ and https://nibware.dev/ (verify component licenses and compatibility before reuse).
