# Dreamscape — AI Dream Journal

## 1. Concept & Vision

Dreamscape is an ethereal, AI-powered dream journal that transforms the fleeting nature of dreams into a living constellation of meaning. Users voice-log or type their dreams upon waking, and Apple Intelligence weaves the recurring threads—symbols, people, places—into a visual "Dream Map" that reveals the subconscious landscape over time. The app feels like gazing into the night sky: deep, vast, and quietly magical.

## 2. Design Language

### Aesthetic Direction
Dark cosmic ethereal — inspired by the night sky, nebulae, and bioluminescence. Not "space theme" in a sci-fi sense, but the ancient human feeling of looking up at stars and wondering.

### Color Palette
| Role | Color | Hex |
|------|-------|-----|
| Background Primary | Deep Void | `#0A0A14` |
| Background Secondary | Night Purple | `#12101F` |
| Surface | Nebula Dark | `#1A1830` |
| Surface Elevated | Cosmic Surface | `#221E38` |
| Accent Primary | Aurora Cyan | `#5EEAD4` |
| Accent Secondary | Nebula Pink | `#C084FC` |
| Accent Tertiary | Star Gold | `#FCD34D` |
| Text Primary | Starlight | `#F0F0FF` |
| Text Secondary | Dim Star | `#8B8BA7` |
| Text Muted | Distant Star | `#5C5C7A` |
| Success | Dream Green | `#34D399` |
| Warning | Amber Glow | `#FBBF24` |
| Error | Meteor Red | `#F87171` |

### Typography
- **Display / Headings:** SF Pro Display (Rounded) — weight 600-700
- **Body:** SF Pro Text — weight 400-500
- **Monospace / Symbols:** SF Mono — for dream timestamps and data
- **Scale:** 12 / 14 / 16 / 18 / 22 / 28 / 34 / 48pt

### Spatial System
- Base unit: 4pt
- Spacing scale: 4, 8, 12, 16, 24, 32, 48, 64pt
- Corner radius: 12pt (cards), 20pt (modals), 9999pt (pills)
- Touch targets: minimum 44pt

### Motion Philosophy
- Slow, breathing animations (400-800ms durations)
- Spring-based easing for organic feel: `animation(.spring(response: 0.6, dampingFraction: 0.8))`
- Fade + gentle scale for reveals
- Star twinkle micro-animations in backgrounds
- No jarring or fast transitions — everything glides

### Visual Assets
- SF Symbols (宇宙/cosmic set: `moon.stars`, `cloud.moon`, `sparkles`, `waveform`)
- Custom star field background (programmatic)
- Glowing orb/pulse effects via SwiftUI gradients and blurs

## 3. Layout & Structure

### Navigation
- **TabView** with 4 tabs:
  1. **Journal** (house) — Dream list/entry
  2. **Map** (sparkles) — Dream Map
  3. **Symbols** (star.circle) — Symbol browser
  4. **Settings** (gear) — Preferences

### Screen Flow
```
TabView
├── Journal Tab
│   ├── DreamListView (home)
│   │   └── DreamDetailView (push)
│   └── DreamEntryView (sheet/fullScreenCover)
├── Map Tab
│   └── DreamMapView
│       └── SymbolDetailView (sheet)
├── Symbols Tab
│   └── SymbolsListView
│       └── SymbolDetailView (push)
└── Settings Tab
    └── SettingsView
```

### Visual Pacing
- Large hero elements (dream cards) with breathing room
- Dense data views (symbol lists) but still with generous padding
- Floating action button for new dream entry on Journal tab

## 4. Features & Interactions (Round 1)

### 4.1 Dream Entry Screen
- **Trigger:** Floating "+" button on Journal tab (bottom trailing)
- **Modes:** Voice recording OR typed entry (segmented picker)
- **Voice Entry:**
  - Tap to start recording, tap again to stop
  - Live waveform visualization
  - Automatic transcription via Speech framework
  - Fallback to typed if transcription fails
- **Typed Entry:**
  - Multi-line TextEditor with placeholder "Describe your dream..."
  - Character count (soft limit 5000 chars)
- **Date/Time:** Auto-set to current time, editable
- **Save:** "Save Dream" button — triggers AI analysis
- **AI Analysis (Apple Intelligence):**
  - Extracts key symbols (people, places, objects, emotions)
  - Generates short summary (2-3 sentences)
  - Tags recurring themes
- **Cancel:** Discard with confirmation dialog

### 4.2 Dream Detail View
- **Header:** Date + time, AI summary
- **Body:** Full transcribed/typed dream text
- **Detected Symbols:** Horizontal scroll of symbol chips
  - Tapping a symbol navigates to SymbolDetailView
- **Actions:** Edit, Delete (with confirmation)

### 4.3 Dream List View
- **Layout:** Vertical scroll of dream cards
- **Card:** Date, summary snippet (2 lines), symbol count badge
- **Sorting:** Most recent first (default)
- **Empty State:** Illustrated prompt — "Your dreams await..."
- **Pull-to-refresh:** Re-analyze dreams for new patterns

### 4.4 Dream Map View
- **Visualization:** Force-directed graph using SwiftUI Canvas
- **Nodes:** Symbol nodes (size = frequency, color = category)
  - People: Pink
  - Places: Blue
  - Objects: Gold
  - Emotions: Cyan
- **Edges:** Lines connecting symbols that appear in the same dream
- **Interactions:**
  - Drag to rearrange
  - Tap node to highlight connections
  - Double-tap to open SymbolDetailView
- **Legend:** Category color key
- **Time Filter:** Segmented control — Week / Month / All Time

### 4.5 Symbol Detail View
- **Header:** Symbol name, category, frequency count
- **Timeline:** Horizontal bar showing occurrences over time
- **Dream List:** All dreams containing this symbol, sorted by date
- **Tap dream:** Navigate to DreamDetailView

### 4.6 Symbols List View
- **Layout:** Alphabetical or by frequency (toggle)
- **Search:** Filter symbols by name
- **Chip:** Symbol name, category color dot, occurrence count

### 4.7 Settings View
- **Cloud Sync Section:**
  - Toggle: "Enable Cloud Sync" (iCloud E2EE)
  - Sync status indicator
- **Notifications Section:**
  - Toggle: "Morning Dream Prompt"
  - Time picker: Wake time (default 7:00 AM)
  - Preview notification text
- **Appearance Section:**
  - Theme: System / Dark Only (Dark is default/only for Round 1)
- **About Section:**
  - App version
  - Privacy policy link
  - Acknowledgments

## 5. Component Inventory

### DreamCard
- States: Default, Highlighted (on tap), Loading (skeleton)
- Corner radius: 16pt
- Background: Surface color with subtle gradient
- Shadow: Soft purple glow (0.3 opacity, 8pt blur)

### SymbolChip
- States: Default, Selected, Category-colored
- Pill shape (corner radius 9999)
- Size: Height 28pt, horizontal padding 12pt
- Icon + text or text only (configurable)

### GlowingButton
- Primary action button with aurora glow effect
- States: Default, Pressed (scale 0.96), Disabled (0.5 opacity)
- Animation: Subtle pulse on appear

### StarFieldBackground
- Programmatic star field (100-200 stars)
- Twinkle animation (opacity oscillation, staggered)
- Static performance-optimized layer

### WaveformView
- Real-time audio visualization
- Bar style with rounded caps
- Aurora gradient fill

### DreamMapGraph
- Canvas-based force simulation
- Smooth spring animations on node movement
- Pinch-to-zoom (future)

## 6. Technical Approach

### Framework & Architecture
- **SwiftUI** (primary UI)
- **iOS 26** target
- **MVVM** architecture
- **Combine** for reactive data flow

### Data Layer
- **SQLite.swift** for local persistence
- Tables: `dreams`, `symbols`, `dream_symbols` (junction)
- **iCloud (CloudKit)** for optional E2EE sync
  - Private database, E2E encrypted with user-controlled key
  - Sync on app launch + pull-to-refresh

### AI / Apple Intelligence
- **NaturalLanguage** framework for entity extraction (symbols)
- **AppIntents** framework for summarization (iOS 26)
- Fallback: Basic keyword extraction if AI unavailable

### Audio
- **AVFoundation** for recording
- **Speech** framework for transcription

### Dependencies (Swift Package Manager)
| Package | Version | Purpose |
|---------|---------|---------|
| SQLite.swift | 0.15.0+ | Local database |
| SnapKit | 5.7.0+ | (Optional, if UIKit needed) |

### Entitlements
- `com.apple.developer.icloud-container-identifiers`
- `com.apple.developer.icloud-services` (CloudKit)
- `com.apple.developer.ubiquity-kvstore-identifier`

### File Structure
```
Dreamscape/
├── App/
│   └── DreamscapeApp.swift
├── Models/
│   ├── Dream.swift
│   ├── Symbol.swift
│   └── Theme.swift
├── Services/
│   ├── DatabaseService.swift
│   ├── DreamAnalysisService.swift
│   ├── SpeechService.swift
│   └── CloudSyncService.swift
├── ViewModels/
│   ├── JournalViewModel.swift
│   ├── DreamMapViewModel.swift
│   ├── SymbolsViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── Components/
│   │   ├── DreamCard.swift
│   │   ├── SymbolChip.swift
│   │   ├── GlowingButton.swift
│   │   ├── StarFieldBackground.swift
│   │   ├── WaveformView.swift
│   │   └── DreamMapCanvas.swift
│   └── Screens/
│       ├── ContentView.swift
│       ├── DreamEntryView.swift
│       ├── DreamDetailView.swift
│       ├── DreamListView.swift
│       ├── DreamMapView.swift
│       ├── SymbolDetailView.swift
│       ├── SymbolsListView.swift
│       └── SettingsView.swift
├── Utilities/
│   ├── Colors.swift
│   ├── Fonts.swift
│   └── Extensions.swift
└── Resources/
    └── Assets.xcassets
```
