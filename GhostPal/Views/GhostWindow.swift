import AppKit

/// Borderless, transparent NSWindow floating over standard windows and Dock.
class GhostWindow: NSWindow {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        // Window & Overlay Architecture Requirements:
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .statusBar // Floating level on top of standard application windows
        self.ignoresMouseEvents = true // Pass all clicks through to Dock & underlying apps
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        self.hasShadow = false
        self.isMovableByWindowBackground = false
        self.isReleasedWhenClosed = false
    }
}
