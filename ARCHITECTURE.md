# Tasbee7 architecture

Feature-based layout. Each folder has one job, so a new feature is a new folder, not edits all over the app.
Xcode picks up files from disk (synchronized folder), so moving or adding files needs no project changes.

```
Tasbee7/
├── App/                  Entry point, tab bar, router (which tab, which screen)
├── DesignSystem/         The design language in code. Views use these, never raw colours or sizes.
│   ├── Theme/            ThemePalette (7 themes) + Theme (current) + colour tokens (.accent, .accentFill, .onAccent, .success …)
│   ├── Tokens/           Spacing, Radius, TextRole (Dynamic Type), Motion (+ reducesMotion)
│   ├── Background/       skyBackground() for main tabs, plainBackground() for pushed screens
│   ├── Components/       PrimaryButtonStyle, card/tile press styles, Artwork, ProgressRing, Pill, FilterChip,
│   │                     SymbolSquare, SectionHeader, StateCard, Toast
│   └── Modifiers/        softScroll(), readableContentMargins()
├── Core/                 Logic with no screens
│   ├── Athkar/           Book model, loader, AthkarCatalog (groups, order, symbols), repository, favourites
│   ├── Search/           Arabic-aware matching (tashkeel, hamza) and the search engine
│   ├── Reminders/        Sunrise/sunset (NOAA), location, the 30-day reminder scheduler, notification taps
│   ├── Preferences/      Reading font and size
│   └── Text/             Arabic plural agreement
├── Features/             One folder per screen or flow
│   ├── Home/ Category/ Reader/ Sebha/ Search/ Settings/ Onboarding/
│   └── Shared/           Navigation destinations every tab shares
└── Resources/            hisn_almuslim.json, fonts
```

## Rules

- Colours come from `Theme` tokens only. The root sets `.tint(Color.accent)`.
- Cards: `.glassEffect(.regular, in: .card)` (radius 38, continuous). Neighbouring glass shares a `GlassEffectContainer`.
- Every scroll view ends with `.softScroll()`. Main tabs use `.skyBackground()`, pushed screens `.plainBackground()`.
- Haptics: pushes get a medium impact automatically (`athkarDestinations`), picks use `.selection`, finishing uses `.success`.
- To add a chapter, add its exact JSON title to a group in `AthkarCatalog`. Unknown titles still show, under "أخرى".
- Storage keys from version 1.x are kept, so favourites, settings and the tasbih count carry over.

## Tests

`Tasbee7Tests/` is a unit-test target hosted in the app (`@testable import Tasbee7`), one folder per kind of test.

- `Performance/`: XCTest `measure` blocks (set baselines per device in Xcode) plus hard budgets in `PerformanceBudget.swift`
  that fail on any machine. Covers loading the book, search (worst case and search-as-you-type), highlighting,
  sunrise/sunset for reminders, and tasbih taps. Run with ⌘U, or `xcodebuild test -scheme Tasbee7 -destination 'platform=iOS Simulator,name=iPhone 17'`.
- `Security/`: Swift Testing suites that guard against tampered or corrupted preferences, hostile notification
  payloads and search input, hidden characters in the book, over-precise stored location, and any widening of
  ATS, permissions, URL schemes or the privacy manifest. Each test uses its own throwaway `UserDefaults` suite.
