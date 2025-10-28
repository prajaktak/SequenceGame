# SequenceGame – Game Design Document

## 1. Game Overview
 SequenceGame is a digital adaptation of the classic Sequence board game for iOS. it is a game where players use cards from their hand to place chips on a board, with the goal of creating a row of five chips in horizontal, vertical, or diagonal line.

## 2. Target Audience & Platform
- Audience: This game can be played by 2 teams with 1 to 4 players in each team. 
- Age: 12 and above
- Platform: iOS (iPhone, iPad)

## 3. Game Objective
To be the first player or team to complete the required number of sequences, which is two sequences in a two-player or two-team game,

## 4. Game Components
- Game board (10x10 grid with card values)
- Two standard decks of cards (no Jokers)
- 50 Blue Chips
- 50 Green Chips
- UI elements 
    Team indicator 
    Turn indicator
    Number of sequence completed along side team indicator
    
## 5. Game Rules and Mechanics
###Setup:
- Lay the game board on a flat surface.
- Separate teams evenly:
- In 2-team games, teammates should alternate positions around the table.
- Shuffle the deck. Players cut cards; the lowest card deals (Aces are high).
- Deal each player the appropriate number of cards:
----------------------------------------
| Number of Players | Cards per Player |
|-------------------|------------------|
| 2                 | 7 cards          |
| 3                 | 6 cards          |
| 4                 | 6 cards          |
| 6                 | 5 cards          |
| 8                 | 4 cards          |
| 9                 | 4 cards          |
| 10                | 3 cards          |
| 12                | 3 cards          |
----------------------------------------
- Each team uses the same color chips.
- Joker cards are not used

###GamePlay:
- Play begins with the player to the left of the dealer and proceeds clockwise
- On your turn:
    * Choose a card from your hand.
    * Place it face-up on your personal discard pile.
    * Place one of your chips on a matching space on the board (each card appears twice on the board).
    * You may play on either space for that card if it’s open.
    * Once placed, chips cannot be removed—except with a one-eyed Jack
- End your turn by drawing a new card from the draw pile.

###Special Cards:
- Two-Eyed Jacks (wild): Place a chip on any open space on the board.
- One-Eyed Jacks (remove): Remove one opponent’s chip from the board (unless it’s part of a completed Sequence). You may not place a chip that turn.
- You can use Jacks strategically at any time on your turn.

###Dead Cards:
- If both matching spaces for a card are occupied, you’re holding a Dead Card.
- On your turn, discard it and say “Dead Card.”
- Draw a replacement card.
- Then take your normal turn.

###Missed Draw Rule:
If you forget to draw a card at the end of your turn and the next player draws theirs, you lose your chance to draw and must finish the game with fewer cards.

###No table talk:
- No coaching or hinting allowed.
- If a teammate says anything inappropriate, every member of that team must discard one card of their choice.

###Draw Pile Runs Out:
- If the draw deck is depleted, shuffle all players’ discard piles together to create a new draw deck.

###Continue Play:
- Play continues clockwise until one team or player reaches the required number of Sequences.
- In games requiring two Sequences, spaces from the first Sequence may be reused in the second.

###Winning the Game:
- 2 players or 2 teams: The first to complete two Sequences wins.

## 6. User Interface (UI) & User Experience (UX)
Sketch or describe the main screens:
- Main Menu (start, continue, help)
- Game Board
- Player hand display
- Team turn indicator
- End game modal (win/tie)
- Onboarding/instructions modal

## 7. Visual and Audio Style
- Art direction: classic board-game style, color schemes, simplicity
- Chip and card designs: flat, colored for visibility
- Animations: chip placement, sequence highlight
- Sounds: chip tap, card deal, sequence complete, win/loss cues
- Optional: background music for ambiance

## 8. Technical Outline
- Language/Framework: Swift, UIKit (or SwiftUI if preferred)
- Architecture notes (MVC/MVVM or other)
- Data: Local state, leaderboards, possible AI (future)
- Device orientation and scaling
- Performance considerations

## 9. Features/Milestones
- Sprint 1: Project setup, rules, and menu
- Sprint 2: Card/chip mechanics, board interaction, turn management
- Sprint 3: Full rules (wilds, sequences), win/tie condition, animations
- Sprint 4: Polish, sound, help screen, release candidate, testing

## 10. Future Enhancements (Optional)
- Online multiplayer
- Stats/leaderboards
- AI/bots for solo play
- Additional rule variants or board themes

## 11. References
- Link to official Sequence rules
https://officialgamerules.org/game-rules/sequence/
- Design inspirations or UI reference links

## 12. Game Theme (Visual System)

- Colors
  - Game screen background: wood texture + subtle radial vignette (black 8% opacity)
  - Menu background (light): parchment/off‑white (#F7F3E9)
  - Menu background (dark): felt green (#1A4D2E), invert text to light
  - Primary accent: deep green (#2F6F3E)
  - Secondary accent: royal blue (#2A5B9D)
  - Text: dark graphite (#1F2937) light mode; light gray (#E5E7EB) dark mode
  - Borders/strokes: warm gray (#D1C7B7) at 60% opacity (1 pt)

- Typography
  - Titles: SF Rounded, Semibold
  - Body: SF, Regular
  - Dynamic Type friendly; suggested sizes: title 20–22, body 15–17, caption 12–13

- Buttons
  - Shape: rounded rectangle (radius 12–16) or capsule for primary CTA
  - Primary fill: vertical gradient (#3A7D4D → #2F6F3E)
  - Outline: 1 pt stroke #113A23 at 20% opacity
  - Shadow: y=1, blur=3, opacity 0.2
  - Pressed state: scale to 0.98 and lighten overlay
  - Secondary: outline style with fill at 10% opacity of accent

- Icons (SF Symbols)
  - Play: play.fill; Continue: clock.arrow.circlepath; Settings: gearshape.fill
  - How to Play: book.fill or questionmark.circle.fill
  - About/Attribution: info.circle.fill; Multiplayer: person.2.fill
  - Sound: speaker.wave.2.fill; Theme: paintbrush.fill; Stats: chart.bar.doc.horizontal.fill

- Spacing & Layout Tokens
  - Horizontal padding: 20; Vertical spacing: 12–16; Button height: 44–52
  - Corner radius: 12 (buttons), 8 (cards/tiles inside menus)

- Motion & Feedback
  - Button press: spring (response 0.25, damping 0.7)
  - Chip placement: scale 0.9 → 1.0 + haptic light
  - Sequence highlight: brief glow/pulse (~800 ms) with sound cue

- Accessibility
  - Contrast ratio ≥ 4.5:1
  - Supports large content sizes (buttons grow vertically)
  - Color‑independent indicators for teams (labels/icons)

- Game Screen Specifics
  - Board underlay: felt green (#134E4A) at ~85% over wood for contrast
  - Turn banner: pill with team color background (85% opacity) + white text
  - Overlays: ultra-thin material or black 40% backdrop

## 13. Main Menu

- Primary Actions
  - Play (Start Game)
  - Continue (only if a saved game exists)

- Secondary Actions
  - How to Play (rules quick start)
  - Settings
    - Teams/players configuration
    - Sounds on/off
    - Theme: Light / Dark / System
    - Colorblind mode (swap red/green for blue/orange)
  - Statistics (optional, later)
  - About
    - Version/build
    - Attributions (LGPL text for vector playing cards)

- Visual Layout
  - Background: parchment (light) or felt (dark) with subtle vignette and paper grain (2–4%)
  - Buttons: primary CTA with gradient; secondary outlined
  - Icons: 18–20 pt leading icon with 8–10 pt text spacing

- Navigation
  - Use NavigationStack; push Settings, How to Play, About
  - Hide Continue if no saved state

---
**Document version:** 0.2 / _Date updated: 28/10/2025

