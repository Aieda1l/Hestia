# Hestia phase 1 — research and brainstorming notes

Checked: 2026-10-15. Status: discovery, **not approved design**. Source/API documentation research is distinct from an Xcode build or iPhone test.

## Product intent

**User-stated:** A gentle iPhone-first companion for original pets/characters and user-provided oshi art; low-friction adoption or import; expressive in-app animation; truthful widget/Live Activity/Island representations; native accessibility; warm lavender/plum direction; local-first and no mandatory account. Hestia refers to the hearth and home.

**Hypothesis to validate:** An immediate character and a credible Home Screen widget preview create more delight and retention than a feature-rich editor or timer-first setup. Target one-minute adoption path and zero mandatory account/network access. Neither preference nor retention is yet established by research with users.

## Repository evidence inventory

| Feature / input | Actual evidence | Verification | Gap or question |
|---|---|---|---|
| Working contract | AGENTS.md, 202 lines | VERIFIED: read in selected /projects/Hestia | Project instructions apply |
| Skills | .agents/skills contains 17 folders; SKILLS_MANIFEST.md | VERIFIED: directory and manifest inspection | Manifest is titled HEPHAESTUS, from an unrelated project; evaluate before using task-specific skills |
| iOS targets and XcodeGen | project.yml absent; App/, Shared/, Widget/ absent | VERIFIED: directory inspection and rg --files | Earlier starter inaccessible here |
| Artwork import, model, persistence, animation, widgets, Live Activities | No Swift source files in selected folder | BLOCKED: no code to inspect | Cannot establish implementation or conduct code-level gap analysis |
| Signing, App Group, tests, assets | No project/entitlement/test/asset files | BLOCKED | Requires real starter or approved future project |
| Documentation and active plans | docs/ absent at initial inspection | VERIFIED | Phase 1 creates only discovery notes |
| Git history | git status --short --branch and git log -4 --oneline returned fatal: not a git repository | VERIFIED command result | No commits or clean-worktree state can be claimed |
| Native toolchain | Windows NT 10.0.26200; Get-Command found git, rg, Python; no xcodebuild, xcodegen, swift, swiftc | VERIFIED command output | Xcode/simulator/signing/device tests not verified in this environment |

Do not infer the source exists from the past-tense description in AGENTS.md. HTML mockup, screenshots, Boonstra whitepaper, and starter archive were not found in the selected Hestia folder. Absence here does not prove they do not exist elsewhere.

## Apple capabilities: documentation verified, native behavior pending

The full surface matrix is in IOS_CAPABILITY_MATRIX.md.

1. **In-app image animation** — Apple's Image I/O offers CGImageSource metadata/thumbnail access and GIF/APNG frame animation APIs. PNG/JPEG stills and user-provided GIF animation are feasible design candidates. Decode memory, alpha appearance, GIF disposal/loop timing, corrupt files, and the actual display implementation require a Mac/device probe. Apple: https://developer.apple.com/documentation/imageio and https://developer.apple.com/documentation/imageio/gif-image-properties (checked 2026-10-15).
2. **Widgets** — WidgetKit renders in a separate process, serves snapshots/timelines with reload budgets, and may display timeline updates later than requested. A continuously looping GIF in a Home Screen or Lock Screen widget is not a feature to promise. Apple documents 40–70 daily reloads as a typical budget for frequently viewed widgets, not an entitlement or guaranteed interval; timeline entries generally should be at least about five minutes apart. Widget and Live Activity data-update animations last at most two seconds. Sources: https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date and https://developer.apple.com/documentation/widgetkit/animating-data-updates-in-widgets-and-live-activities (checked 2026-10-15).
3. **Live Activities** — Apple recommends tasks/events with defined start/end, not indefinite decoration. Maximum active lifetime is eight hours; an ended activity can remain on Lock Screen for up to four additional hours (up to 12 hours total). Static plus dynamic ActivityKit data is limited to 4 KB. The Live Activity UI cannot make network calls; images must respect presentation sizes. Foreground start is normal; LiveActivityIntent offers a documented special case. Check areActivitiesEnabled; model stale and dismissed states. Sources: https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities, https://developer.apple.com/documentation/activitykit/activityauthorizationinfo, https://developer.apple.com/design/human-interface-guidelines/live-activities (checked 2026-10-15).
4. **Dynamic Island** — A Live Activity can define compact leading/trailing, minimal, and expanded presentations for supported hardware. The system decides which appears and when. Not supported: a guaranteed always-on floating character or unrestricted looping GIF on the Island. A Lock Screen Live Activity and in-app animation are appropriate fallbacks. Sources: https://developer.apple.com/documentation/widgetkit/dynamicisland and https://developer.apple.com/design/human-interface-guidelines/live-activities (checked 2026-10-15).
5. **Countdown** — SwiftUI has Text(timerInterval:pauseTime:countsDown:showsHours:) for a system-rendered changing countdown; it is a candidate for event progress without manual per-second timeline reload. Timer behavior, session-end presentation, and expiration still need native testing. Source: https://developer.apple.com/documentation/swiftui/text/init(timerinterval:pausetime:countsdown:showshours:) (checked 2026-10-15).
6. **Local files, photos, sharing** — SwiftUI PhotosPicker uses user selection; Apple's photo picker does not require broad photo-library permission for basic selection. **GIF fidelity is an open technical question:** Apple notes SwiftUI Image's Transferable conformance handles PNG only, and picker retrieval may fail when an iCloud asset is inaccessible. Import original GIF data/file representation, preserve its animated frames and test the round-trip; do not assume loadTransferable(Image.self) preserves GIF. SwiftUI fileImporter supplies security-scoped URLs, requiring startAccessingSecurityScopedResource and release. App Groups permit app/extension shared preferences and files when both have appropriate entitlements. Sources: https://developer.apple.com/documentation/photokit/bringing-photos-picker-to-your-swiftui-app, https://developer.apple.com/documentation/photosui/photospickeritem, https://developer.apple.com/documentation/photokit/selecting-photos-and-videos-in-ios, https://developer.apple.com/documentation/swiftui/view/fileimporter(ispresented:allowedcontenttypes:allowsmultipleselection:oncompletion:oncancellation:), https://developer.apple.com/documentation/xcode/configuring-app-groups (checked 2026-10-15).
7. **Accessibility and energy** — Apple recommends reducing automatically repeating motion for Reduce Motion; SwiftUI provides accessibilityReduceMotion and accessibilityPlayAnimatedImages, the latter saying disabled animated images must not play automatically. Always-On can suppress system-surface animation. Use spoken pet name/state, a textual countdown, scalable layout and still poster when animations are disabled; test VoiceOver, Dynamic Type, contrast, appearance/tint mode, and low power/visibility. Sources: https://developer.apple.com/design/human-interface-guidelines/accessibility, https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion, https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityplayanimatedimages, https://developer.apple.com/design/human-interface-guidelines/widgets, https://developer.apple.com/documentation/xcode/improving-your-app-s-rendering-efficiency (checked 2026-10-15).
8. **Review/IP** — Use original or authorized starter art; no bundled borrowed characters or franchise marks. Private local imported images differ from hosting a public user-generated content feed; revisit moderation requirements only if sharing is introduced. Source: https://developer.apple.com/app-store/review/guidelines/ (checked 2026-10-15; release interpretation remains subject to App Review).

## Ecosystem / UI pattern research

| Reference | Source-observed pattern | Design lesson / boundary |
|---|---|---|
| Widgetable | Shared virtual pets and Home/Lock widgets; https://apps.apple.com/us/app/widgetable-besties-couples/id1641107226 | Persistent emotional presence is relevant. Social co-care, network, and complex pet economy are outside a local-first MVP. |
| Finch | Pet grows through goals/self-care; https://apps.apple.com/us/app/finch-self-care-pet/id1528595748 | Attachment can grow from tiny rituals. Its broader health/habit ecosystem is outside this MVP. |
| Focus Friend | Character accompanies a focus timer and app listing advertises a Lock Screen Live Activity; https://apps.apple.com/us/app/focus-friend-by-hank-green/id6742278016 | A session gives ActivityKit a genuine time-bounded purpose. No reward economy required for Hestia. |
| Pixel Pals | Third-party write-up describes an Island/Lock pet using Live Activity: https://fueled.com/blog/pixel-pals/ | Validate the device experience against Apple APIs; marketing visuals are not a platform guarantee. |

**Anima Engine:** exact product identity, platform and reusable rights have not been substantiated in sources checked. Retain as inspiration only; do not claim feature equivalence or copy art/code/UI.

**ComponentsKit:** documentation lists iOS 15+, Swift package installation; repo describes SwiftUI/UIKit components under MIT license, which requires retaining the license/copyright notice: https://componentskit.dev/docs/getting-started/installation and https://github.com/componentskit/ComponentsKit/blob/main/LICENSE. Candidate for standard controls, not needed without a native SwiftUI gap. No dependency added.

**Nibware:** declares iOS 17+ copy-in pure SwiftUI components; first-party component license grants commercial app shipping/modification without attribution but prohibits catalog redistribution and automated scraping; community submissions are MIT: https://nibware.dev/ and https://nibware.dev/terms (last terms update 2026-07-27; checked 2026-10-15). Validate individual component provenance, Dynamic Type and VoiceOver, and actual compile success before use. None copied.

Native SwiftUI controls, layout, SF Symbols, and materials are the default. A small Hestia-specific visual system better supports consistent cozy tone than a dependency collection.

## Initial design alternatives (superseded as primary direction by user correction)

**A. Companion-first (initial recommendation, now superseded; M effort relative).** Audience: character/oshi fans who want a quiet daily presence. First-run: choose a starter or import art → name/accept default → see character animate in app → preview honest Home Screen widget → follow short widget-add guidance; optional session CTA comes next. Scope: one selected companion, a small library, PNG/JPEG/GIF import with validated decoding, local storage and static widget art, later time-bounded focus Live Activity. Excludes social/accounts, complex frame authoring, gamification. Message: 'Animated in Hestia. Your widget shows a still; after you change companions, Hestia asks iOS to refresh it. Timing may vary.' Experiment: a new user chooses a character and can explain widget behavior in ~60 seconds; observe actual widget installation on phone.

**B. Session-first (M effort, higher lifecycle risk).** Audience: students/readers who want a friendly focus timer. First-run: choose starter → choose short duration → start focus → see Lock Screen/Island timer → return to end/share private satisfaction. Scope: timed focus, permission/expiry UI, compact/minimal/expanded/Lock Screen, local chosen starter; widgets/import can follow. Excludes timers without real end, always-on pets, rewards economy. Message: 'Your buddy joins a timed focus session; system visibility is controlled by iOS.' Experiment: user starts/ends a timer and correctly predicts when Island will show; requires eligible/noneligible iPhones and denial case.

**C. Studio-first (L effort).** Audience: OC artists who prioritize expressive editing. First-run: import image → choose framing/background → name → preview in-app animation and widget still → save. Scope: detailed editing, cropping, pose/frame selection, style preview. Excludes system session initially. Main risk: editing features obscure the one-minute emotional payoff and expand import/animation correctness scope. Experiment: an artist can import one valid GIF and produce a saved, accurate still preview in under 90 seconds; measure errors and confusion.

All three share the same truth: in-app animation can run while the app is active; WidgetKit snapshots and ActivityKit state changes are system-managed. A family-less/Island-less phone remains useful through in-app art and a widget.

## Risk register

| Priority | Impact / evidence | Cheapest validation | Fallback / owner |
|---|---|---|---|
| High — missing starter/source | No Swift/project.yml/entitlements/tests; cannot verify old prototype | Locate intended starter, compare files and git state before code changes | New scaffold only after separate approved written design; owner: repository lead |
| High — false Island/widget motion promise | Official WidgetKit/ActivityKit lifecycle; short animations only | Real-device side-by-side comparison of in-app GIF, widget still, active Island timer | Plain honest previews and accurate copy; owner: iOS engineer + UX |
| High — import fidelity and decode-memory hazards | PhotosPicker Image Transferable only handles PNG; GIF may be transcoded; Image I/O expands compressed frames | Test Photos and Files GIF preservation, plus bounded/corrupt GIF stress fixtures on Mac with memory and timing measurements | Provide Files route, reject costly assets with actionable message; show still; owner: iOS engineer |
| High — App Group and signing | Entitlement and container required; no project present | Xcode signed app/extension + relaunch/widget shared-file read | Explicit unavailable state; owner: iOS engineer |
| Medium — Live Activity expiry/stale/dismissal | 8-hour ActivityKit limit, permission switches, stale states | Start/end/relaunch/force-quit/expiry smoke tests on compatible + non-Island devices | In-app timer with explicit restoration and end state; owner: iOS engineer/QA |
| Medium — widget rendering/tint | Timeline budget, content margins, system appearance | Test small/medium, light/dark/tinted/Always-On/large text | Legible static portrait/text; owner: UX/QA |
| Medium — licensed artwork/fan art | Apple IP/App Review requirements | Starter license ledger and upload-rights copy | Original placeholder starter assets; user-local imported art only; owner: product |
| Medium — motion and accessibility | Apple HIG Reduce Motion/VoiceOver guidance | Motion disabled, VoiceOver and Dynamic Type walk-through | Still or reduced-motion artwork, descriptive labels; owner: UX/QA |
| Medium — widget installation friction | Widget addition is system UI; accuracy needs usability check | Watch 3-5 people follow instructions without help | In-app character remains delightful with no widget; owner: product |
| Low — UI-kit adoption | Third-party license/maintenance and style cost | Review one specific component and compile in future | Native SwiftUI; owner: iOS engineer |

## First feasibility probes after appropriate approval

1. Source restoration and Mac toolchain check: identify exact iOS project, targets, effective minimum OS, signing and extension schemes; build before behavior assertions.
2. Import benchmark: valid PNG/JPEG, small transparent/opaque GIF, corrupt and very large GIF; record decoded frame memory and stop-on-background/Reduce Motion behavior.
3. Shared selection: select and relaunch, verify widget reads the same selected art from correct App Group; test group-container failure.
4. Real-device surfaces: eligible Island iPhone and iPhone without Island; start a 1-minute/25-minute timer, check permission off, backgrounds, expiry, dismiss, restart, all layouts, and accurate marketing copy.
5. One-minute first-run usability observation: adoption → preview → manual widget addition; ask user what is animated and what is static.

## Open decisions and blockers

- Superseded: original proposal for a Home Screen widget as primary placement. The user subsequently specified an **animated Dynamic Island character as the main identity**.
- Source blocker: earlier iOS starter and mockup are absent from selected Hestia checkout. Do not silently reconstruct or overwrite.
- Toolchain blocker: Windows host lacks Mac Xcode/simulator/connected iPhone verification for this session.
- Asset rights: no reviewed/approved Hestia starter-character art or attribution ledger located.
- Design system and storyboard remain proposals, not approved implementation specifications.

## User correction — October 15, 2026: Island character is the product identity

**USER-STATED:** "I want the dynamic island animated character to be the main identity. It should be inspired by Anima Engine, but for iOS." This supersedes the preliminary companion-first/widget-primary recommendation. The emotional anchor is seeing a personalized expressive character in the Dynamic Island; adopt/import/studio/other widgets should serve that primary experience. **Do not treat the prior companion-first recommendation as accepted.**

### Newly confirmed reference

The apparent inspiration is MarroIndustries' **Anima Engine** on Steam, a Windows desktop animation utility released February 15, 2025. Its official listing describes customizable desktop animations and imported GIF/APNG/WebP/sprite/video media, with user-scale editing and optional AI background removal. URL: https://store.steampowered.com/app/3474900/Anima_Engine/ (checked 2026-10-15). This clarifies the intended delight (animated presence and personal imported assets), but is a **Windows desktop** implementation, not proof of iOS Island capabilities. No Anima Engine art or source has been copied.

**Closest iOS analogy:** Pixel Pals' App Store listing confirms user-customizable virtual pets using Live Activities and the Dynamic Island; reporting describes them visually moving around the Island. Sources: https://apps.apple.com/us/app/pixel-pals-widget-pet-game/id6443919232, https://techcrunch.com/2023/09/22/pixepixel-pals-delivers-a-cute-and-clever-update-that-takes-advantage-of-new-ios-features/ (checked 2026-10-15). The exact rendering mechanism, frame rate, battery behavior, OS reliability and App Review interpretation are **unverified**; do not present a third-party effect as an Apple-supported arbitrary GIF loop.

### Native platform feasibility boundary

- **VERIFIED in Apple docs:** Dynamic Island is a Live Activity presentation; system decides visible layout and whether it is displayed. Its compact/minimal/expanded content must pair with a Lock Screen presentation. A Live Activity is tied to an ongoing task/event and lasts at most eight hours active. Sources: https://developer.apple.com/design/human-interface-guidelines/live-activities and https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities (checked 2026-10-15).
- **VERIFIED in Apple docs:** Live Activity/widget SwiftUI animations are for **state/content changes** and have a maximum duration of two seconds; Always-On with reduced luminance suppresses animation. Source: https://developer.apple.com/documentation/widgetkit/animating-data-updates-in-widgets-and-live-activities (checked 2026-10-15).
- **NEEDS SPIKE:** Could minimal low-frame-rate character motion be reproduced during an eligible, ongoing ActivityKit session using public APIs, without frequent background work or misuse of timer/text rendering? Some community discussions speculate about time-driven glyph techniques; those are not a verified or endorsed native solution. Test on current iOS/eligible hardware and review relevant App Review guidance before committing to the effect.
- **NOT A SUPPORTED PROMISE:** arbitrary imported GIF/video running continuously in the Island, an all-day desktop overlay, a guaranteed always-visible character, per-frame background refresh or indefinite decorative Live Activity.

### Revised Island-first options (PROPOSED; no direction approval yet)

**I. Expressive Island session — recommended reliable baseline (M).** First-run: choose a starter → pick a task/session duration (focus, reading or other genuine active task) → start the buddy session → see a readable character pose/short transition and countdown in compact/minimal/expanded Island → tap to manage/end; non-Island fallback is Lock Screen Live Activity. In-app studio and Home Screen widget follow this identity. Emotion: an expressive small friend accompanies real activity. Reliable baseline animation: momentary state transitions tied to meaningful state changes. Experiment: user can activate and end a session and identify character/mood and remaining time on eligible hardware. Pass only if actual ActivityKit test confirms layouts, denied permission, end/dismiss and accurate copy.

**II. Island motion experiment — conditional research candidate (M–L, uncertain).** Same legitimate bounded session and layouts as I, but a separate feasibility spike tests whether a small, original 2–4-frame idle effect can appear while running without relying on background loops, unsupported hacks or misrepresented Apple update budgets. Acceptance for retaining it: a current iPhone with Dynamic Island shows perceptible movement for a representative session in both locked/unlocked conditions at reasonable battery cost and respects reduced motion; App Review policy fit is reviewed. If results fail, fall back to option I and fluid in-app animation. **This is an experiment, not a promised v1 behavior.**

**III. Anima-style full motion on the Island (unsupported target as written).** User imports any animated GIF/APNG and expects its original frame rate 24/7, including while app is closed. That seamless desktop-style overlay is not a documented ActivityKit capability and conflicts with system-controlled visibility, update duration and eight-hour limit. Offer truthful alternate: full GIF in foreground app plus compact Island session, or reconsider the platform if uninterrupted overlay is non-negotiable. **Not recommended as an MVP commitment.**

### One approval-relevant question

Is the must-have **continuous autonomous looping GIF-like motion in the Dynamic Island**, or would an **expressive Island buddy with short character transitions during a real time-bounded session**, optionally enhanced by a separately verified minimal idle-motion experiment, satisfy the desired product identity?

**Resolved in user follow-up (2026-10-15):** "Occasional animations are fine if continuous looping motion isn't possible." The Island-first identity is retained and short state-driven expression is the reliable proposed baseline. A time-bounded focus session is proposed as the purposeful Live Activity context; no written design has yet been approved. See [canonical draft written design](superpowers/specs/2026-10-15-island-first-companion-design.md). Do not implement or treat continuous idle motion as promised.
