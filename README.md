# SequenceGame

A SwiftUI implementation of the Sequence board game with a themed main menu, dynamic card rendering, and a responsive board.

## Requirements

- macOS 14.5 or later (Sonoma)
- Xcode 16.x (iOS SDK 18.x)
- iOS Simulator (iPhone 16 or later recommended)
- Swift 5.10+
- SwiftLint (optional; a lint phase runs if installed)

## Getting Started

1. Clone or download this repository.
2. Open the Xcode project:
   - File > Open…
   - Select `SequenceGame/SequenceGame/SequenceGame.xcodeproj`
3. Select a simulator target (e.g., iPhone 16).
4. Build & Run (⌘R).

## Project Structure

```
SequenceGame/
  SequenceGame/
    SequenceGame/
      Assets.xcassets/           # Colors, images, card assets, wood textures
      Views/                     # SwiftUI screens and components
        MainMenu.swift           # Themed main menu
        HelpView.swift           # How-to-play guidance
        CreditsView.swift        # About & attributions
        SettingsView.swift       # Settings UI
        SequenceGameView.swift   # Game screen shell
        SequenceBoardView.swift  # Board UI
        CardFaceView.swift       # Card face with image/fallback pips
        CardPipView.swift        # Data-driven pips fallback
        TileView.swift           # Board tile
        Theme/
          ThemeColor.swift       # Semantic colors
          PrimaryButtonStyle.swift
          SecondaryButtonStyle.swift
        ScatteredItem.swift      # Support type for scattered header visuals
      models/                    # Game model types (Board, Card, Deck, etc.)
      SequenceGameApp.swift      # App entry
```

## Theme & Assets

- Colors live in `Assets.xcassets/Theme/*` and are accessed via `ThemeColor`:
  - `accentPrimary`, `accentSecondary`, `accentTertiary`
  - `backgroundMenu`, `backgroundGame`, `boardFelt`
  - `textPrimary`, `textOnAccent`, `border`, `teamBlue`, `teamGreen`
- Menu button gradient blends:
  - Button 1: `accentPrimary → accentSecondary`
  - Button 2: `accentPrimary → accentTertiary`
  - Button 3: `accentPrimary → accentSecondary`
  - Button 4: `accentPrimary → accentTertiary`
  - Button 5: `accentPrimary → accentSecondary`

### Card Center Images

- Uses center images when available; falls back to pips (data-driven layouts).
- Naming pattern: `card_center_<rank>_<suit>` (e.g., `card_center_10_spade`).
- Suits are singular: `spade`, `heart`, `club`, `diamond`.

## Build & Run

- In Xcode, choose the `SequenceGame` scheme and press ⌘R.
- SwiftLint is optional; without it, the build still succeeds.

## Troubleshooting

- SwiftLint warnings: install via Homebrew `brew install swiftlint`.
- Missing assets: ensure items in `Assets.xcassets` are in the app target.
- Backgrounds: verify `wood`, `woodDark` images and `BoardFelt` color exist.

## Attributions

- Vectorized Playing Cards 3.2 — LGPL 3.0. See Credits/Attributions in-app.

## License

This project is for learning/personal use. Third‑party assets retain original licenses.
