import AppKit
import Foundation

struct DockInfo {
    let topY: CGFloat
    let minX: CGFloat
    let maxX: CGFloat
    let isBottomDock: Bool
    let screenFrame: NSRect
    let visibleFrame: NSRect
}

/// Helper service to dynamically calculate macOS Dock boundaries and screen frame.
class DockManager {
    static let shared = DockManager()
    
    private(set) var dockInfo: DockInfo
    
    init() {
        self.dockInfo = DockManager.calculateDockInfo()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }
    
    @objc private func screenParametersChanged() {
        self.dockInfo = DockManager.calculateDockInfo()
    }
    
    static func calculateDockInfo() -> DockInfo {
        let screen = NSScreen.main ?? NSScreen.screens.first!
        let screenFrame = screen.frame
        let visibleFrame = screen.visibleFrame
        
        // Detect bottom dock height
        let bottomDockHeight = visibleFrame.minY
        let isBottomDock = bottomDockHeight > 0
        
        // Top line of Dock in screen coordinates (0,0 is bottom-left)
        let topY = isBottomDock ? bottomDockHeight : 50.0
        
        // Horizontal boundaries skim across visible width with padding for ghost width
        let minX = visibleFrame.minX + 50.0
        let maxX = visibleFrame.maxX - 50.0
        
        return DockInfo(
            topY: topY,
            minX: minX,
            maxX: max(minX + 100.0, maxX),
            isBottomDock: isBottomDock,
            screenFrame: screenFrame,
            visibleFrame: visibleFrame
        )
    }
}
