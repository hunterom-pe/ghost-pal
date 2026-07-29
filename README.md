# GhostPal 👻 - macOS Dock Companion Desktop Pet

**GhostPal** is a native macOS background desktop pet built in Swift and SwiftUI. It features a cute, spooky procedural ghost that floats back and forth along the top line of the macOS Dock, bobbing up and down, periodically waving, falling asleep when you are idle, and waking up with a happy jump when clicked.

---

## 🌟 Key Features & Requirements Met

1. **Background Agent App (`LSUIElement = true`)**
   - Configured in `Info.plist` as a menu bar agent app so it does not take up space or add an extra icon in your macOS Dock.
2. **Menu Bar Status Item (`NSStatusItem`)**
   - Displays a ghost icon in the macOS menu bar with a context menu containing **Quit Ghost**.
3. **Transparent Floating Overlay Window**
   - Borderless `NSWindow` with `isOpaque = false` and `backgroundColor = .clear`.
   - `window.level = .statusBar` floats on top of standard application windows and over the Dock.
   - `window.ignoresMouseEvents = true` guarantees that all mouse clicks pass cleanly through to Dock app icons and windows below.
4. **Dynamic Dock & Screen Calculation (`DockManager`)**
   - Reads `NSScreen.main.visibleFrame` and `NSScreen.main.frame` to detect Dock location, top edge height ($Y_{\text{dock}}$), and horizontal patrol limits ($X_{\text{min}}$ ... $X_{\text{max}}$). Automatically updates on screen resolution changes.
5. **Procedural Vector Graphics & SwiftUI Canvas**
   - 100% procedural vector rendering via SwiftUI `Canvas` with zero PNG asset dependencies.
   - **Awake / Patrol**: Open eyes with shiny highlights, horizontal glide motion, and sine wave vertical bobbing loop ($Y = Y_{\text{dock}} + \sin(t) \times 8$).
   - **Waving**: Raised stubby arm swaying back and forth (triggers automatically every 60–120s for 3s).
   - **Sleeping**: Closed `u u` eyes, resting position on Dock bar, with animated floating white `z Z Z` particles drifting upward.
6. **System Idle & Click-to-Wake**
   - `IdleTracker` monitors system inactivity via `CGEventSource`. Transitions to Sleeping mode after 3 minutes (180s) of user idle time.
   - `NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown)` listens for mouse clicks inside the ghost's floating area while sleeping to trigger a happy wake-up jump animation.

---

## 📁 Project Structure

```
ghost-pal/
├── GhostPal.xcodeproj/           # Xcode Project bundle
├── Package.swift                 # Swift Package Manager manifest
├── README.md                     # Documentation
└── GhostPal/
    ├── Info.plist                # App Configuration (LSUIElement = true)
    ├── App/
    │   ├── GhostPalApp.swift     # Main SwiftUI entry point (@main)
    │   └── AppDelegate.swift     # NSStatusItem, Window setup, State Machine & Click Monitor
    ├── Models/
    │   └── GhostState.swift      # State Machine (Patrol, Waving, Sleeping, WakingUp)
    ├── Services/
    │   ├── DockManager.swift     # Dynamic macOS Dock bounds calculation
    │   └── IdleTracker.swift     # System idle time tracking (3 min sleep)
    └── Views/
        ├── GhostCanvasView.swift # Procedural SwiftUI Canvas ghost & Z-particles FX
        └── GhostWindow.swift     # Borderless transparent NSWindow overlay
```

---

## 🛠 Building & Running

### Option 1: Open in Xcode
1. Double-click `GhostPal.xcodeproj` to open the project in Xcode.
2. Select the `GhostPal` scheme and target **My Mac**.
3. Press **⌘R** (Run).

### Option 2: Build via Command Line (SwiftPM / xcodebuild)
```bash
# Build via Xcode CLI
xcodebuild -project GhostPal.xcodeproj -scheme GhostPal build

# Or build via Swift Package Manager
swift build
```

---

## 🎮 How to Interact
- **Patrol & Wave**: Watch your ghost companion float along the top line of your Dock.
- **Sleep**: Leave your Mac untouched for 3 minutes; the ghost will sink onto the Dock and start emitting floating `z Z Z` particles.
- **Wake Up**: Left-click on the sleeping ghost to trigger a happy jump animation and wake it up!
- **Quit**: Click the ghost icon in your macOS Menu Bar at top-right and select **Quit Ghost**.
