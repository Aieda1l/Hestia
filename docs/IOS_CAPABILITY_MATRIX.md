# Hestia — iOS surface capability matrix

Checked: 2026-10-15. **VERIFIED** here means Apple documentation inspected; no claim of native app build, simulator execution or physical-device validation. The Hestia application source is absent from the selected workspace.

**Product priority update (2026-10-15):** The user explicitly chose an **animated Dynamic Island character as Hestia's primary identity**, inspired by MarroIndustries' Windows desktop Anima Engine, and accepted **occasional character motion** if continuous looping proves unavailable. The system's constraints below still apply. Brief state-driven transitions are the proposed baseline, subject to actual device verification. Treat autonomous idle blinking/repeating motion as an unverified feasibility question rather than a deliverable; do not assume an arbitrary GIF can loop in a Live Activity. A meaningful time-bounded session remains the credible ActivityKit context. See RESEARCH_NOTES.md and the canonical draft spec for the proposed Island-first experience.

| Surface | Desired character experience | Apple-supported approach | Real animation behavior | iOS/hardware condition | Fallback | Evidence / confidence |
|---|---|---|---|---|---|---|
| In-app library/studio | Expressive adopted pet or imported OC | SwiftUI/UIKit with Image I/O frame decode/playback for GIF/APNG, static PNG/JPEG and layer/transform state | True playback while app is running; profile frame memory/battery; adapt to Reduce Motion | Intended iOS 17+ is historical target, not currently proven; no Island hardware necessary | Static poster / first useful frame, description and retry on invalid file | VERIFIED doc-level feasibility: Apple Image I/O; BLOCKED app/device verification |
| Home Screen widget | Small always-glanceable companion | WidgetKit family systemSmall or systemMedium, timeline/config or selected App Group model, static portrait and contextual label | Static view between refreshes; supported data-update transitions at most 2 seconds; not an endless GIF canvas | Supported iPhone/iOS widget families; dynamic refresh is budgeted/system-owned | Local in-app art and clear manual-add guidance | VERIFIED Apple WidgetKit doc; BLOCKED rendering test |
| Lock Screen accessory widget (optional later) | Tiny companion cue | WidgetKit accessory family, legible monochrome/accent treatment | Static symbol/portrait/timeline state with system-managed updates | Eligible Lock Screen accessory family; visibility and tint depend on system and device | Home Screen widget or in-app preview | VERIFIED WidgetKit docs; priority/design not approved |
| Lock Screen Live Activity | Buddy during study/reading/focus | ActivityKit for an explicit finite task; Lock Screen ActivityConfiguration with companion still and system timer text | State transitions and countdown; not continuous GIF. Starts/ends through ActivityKit, may be dismissed or stale | Authorization enabled; valid Live Activity target/entitlements; intended iOS 17+ to be checked in build | In-app focus timer and explanation when unavailable | VERIFIED doc: ActivityKit, HIG; BLOCKED native run |
| Dynamic Island | Character and countdown during an active task | ActivityKit compact leading/trailing, minimal and expanded content in WidgetKit extension | System decides layout/visibility; updates/short animations; no guaranteed endless animation or overlay | Only Dynamic Island-equipped iPhone hardware and when the system shows the activity | Lock Screen Live Activity, Home Screen widget, in-app session | VERIFIED doc: DynamicIsland API and HIG; BLOCKED eligible device test |

**Animation experiment (unknown):** Pixel Pals demonstrates a third-party marketing example of animated-looking pets in Live Activities; no source or device observation yet establishes a supported general-purpose character animation API. Test any small frame/time-driven technique against Apple's two-second **update animation** limit, ActivityKit eligibility, battery/Always-On/Reduce Motion behavior, and App Review rules. Sources checked 2026-10-15: https://apps.apple.com/us/app/pixel-pals-widget-pet-game/id6443919232 and https://developer.apple.com/documentation/widgetkit/animating-data-updates-in-widgets-and-live-activities.

## Platform constraints

- WidgetKit does **not** continually execute the widget extension; timelines and reload calls are subject to an adaptive daily budget. Apple says often 40–70 refreshes/day for frequently viewed widgets, not guaranteed. Do not schedule sprite frames as repeated timeline entries.
- Widget/Live Activity **data-update animations last no more than two seconds**; Always-On mode suppresses animation. Keep an accessible static state at all times.
- ActivityKit Live Activities have a defined beginning and end, can run **up to eight hours**, and may remain on Lock Screen for **up to four hours more**. The system removes a finished activity from the Island and can dismiss or preempt an activity.
- ActivityKit static+dynamic data limit is **4 KB**. Do not encode full artwork in ActivityAttributes/ContentState. Artwork resource loading, presentation dimensions and shared-storage behavior must be tested in a signed widget extension.
- Typically start Live Activity while app is in foreground; LiveActivityIntent is a documented exception. Ask ActivityAuthorizationInfo.areActivitiesEnabled, handle off/stale/dismissed/cancelled, provide local timer fallback.
- SwiftUI Text(timerInterval:...) is an appropriate candidate for time display; lifecycle ending still needs tested behavior when the app is suspended.
- ActivityKit staleDate marks data outdated; **stale does not mean ended**. Reconcile Activity.activities and state updates after app relaunch and choose a clear final state and dismissal policy; background execution is not guaranteed simply because a timer elapses.
- App Groups require the shared container entitlement on both app and extension; failure must not silently select unrelated local data. PhotosPicker/fileImporter enable least-permission user imports; security-scoped URLs need explicit access/release.
- Verify PhotosPicker preserves GIF data: SwiftUI Image Transferable supports PNG, so an Image result is insufficient evidence that GIF animation survives. Handle unavailable iCloud assets while offline.
- Honor VoiceOver labels, Dynamic Type, Reduce Motion and accessibilityPlayAnimatedImages, accessible buttons/contrasts, light/dark/tinted widget variants, offline use and local artwork rights.

## Source references — checked 2026-10-15

- Apple Image I/O: https://developer.apple.com/documentation/imageio
- Apple GIF image properties: https://developer.apple.com/documentation/imageio/gif-image-properties
- Apple WidgetKit updates and budgets: https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date
- Apple widget/Live Activity animation limits: https://developer.apple.com/documentation/widgetkit/animating-data-updates-in-widgets-and-live-activities
- Apple widgets HIG: https://developer.apple.com/design/human-interface-guidelines/widgets
- Apple Live Activities design and lifetimes: https://developer.apple.com/design/human-interface-guidelines/live-activities
- Apple ActivityKit implementation constraints and 4 KB: https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities
- Apple Dynamic Island configuration: https://developer.apple.com/documentation/widgetkit/dynamicisland
- Apple ActivityKit permissions: https://developer.apple.com/documentation/activitykit/activityauthorizationinfo
- Apple SwiftUI countdown text: https://developer.apple.com/documentation/swiftui/text/init(timerinterval:pausetime:countsdown:showshours:)
- Apple App Groups: https://developer.apple.com/documentation/xcode/configuring-app-groups
- Apple Photos picker: https://developer.apple.com/documentation/photokit/bringing-photos-picker-to-your-swiftui-app
- Apple PhotosPickerItem format limits: https://developer.apple.com/documentation/photosui/photospickeritem
- Apple File importer: https://developer.apple.com/documentation/swiftui/view/fileimporter(ispresented:allowedcontenttypes:allowsmultipleselection:oncompletion:oncancellation:)
- Apple Reduce Motion: https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityreducemotion
- Apple Animated Images accessibility: https://developer.apple.com/documentation/swiftui/environmentvalues/accessibilityplayanimatedimages

## Verification remaining

Missing project source, Mac/XcodeGen toolchain, simulator and signed physical iPhone. No scheme/build/entitlement, UI, widget, Live Activity, battery, or accessibility test has run. A documented API being available is not proof that Hestia implements it.
