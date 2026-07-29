import AppKit
import SwiftUI
import Combine

/// Main App Delegate coordinating menu bar status item, overlay window, state machine, timers, and click-to-wake.
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var window: GhostWindow!
    private var eventMonitor: Any?
    
    // Core Services & State
    private let dockManager = DockManager.shared
    private let idleTracker = IdleTracker()
    
    // Animation & State Variables
    @Published private(set) var currentState: GhostState = .patrol
    @Published private(set) var facingDirection: FacingDirection = .right
    @Published private(set) var ghostPosition: CGPoint = .zero
    @Published private(set) var animationTime: Double = 0.0
    @Published private(set) var eyeOffsetX: CGFloat = 0.0
    @Published private(set) var headTiltAngle: Double = 0.0
    
    private var timer: Timer?
    private var glideSpeed: CGFloat = 1.4
    private var timeStep: Double = 0.0
    
    // Random Timers
    private var nextWaveTime: Double = 60.0
    private var waveEndTime: Double = 0.0
    
    private var nextLookAroundTime: Double = 30.0
    private var lookAroundEndTime: Double = 0.0
    
    // Wake-up Jump Physics
    private var jumpVelocityY: CGFloat = 0.0
    private var jumpOffsetY: CGFloat = 0.0
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupOverlayWindow()
        setupStateAndPosition()
        setupGlobalClickMonitor()
        startAnimationLoop()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        timer?.invalidate()
    }
    
    // MARK: - 1. Menu Bar NSStatusItem Setup
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = createGhostMenuIcon()
            button.toolTip = "GhostPal - Dock Companion"
        }
        
        let menu = NSMenu()
        let titleItem = NSMenuItem(title: "GhostPal (Dock Companion)", action: nil, keyEquivalent: "")
        titleItem.isEnabled = false
        menu.addItem(titleItem)
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit Ghost", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
    private func createGhostMenuIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            let path = NSBezierPath()
            path.appendArc(withCenter: NSPoint(x: 9, y: 11), radius: 5.5, startAngle: 0, endAngle: 180)
            path.line(to: NSPoint(x: 3.5, y: 4.5))
            path.curve(to: NSPoint(x: 7, y: 4), controlPoint1: NSPoint(x: 4.5, y: 3), controlPoint2: NSPoint(x: 6, y: 3))
            path.curve(to: NSPoint(x: 11, y: 4), controlPoint1: NSPoint(x: 8, y: 5), controlPoint2: NSPoint(x: 10, y: 5))
            path.curve(to: NSPoint(x: 14.5, y: 4.5), controlPoint1: NSPoint(x: 12, y: 3), controlPoint2: NSPoint(x: 13.5, y: 3))
            path.line(to: NSPoint(x: 14.5, y: 11))
            path.close()
            
            NSColor.black.setFill()
            path.fill()
            
            let leftEye = NSRect(x: 6.5, y: 9.5, width: 1.8, height: 2.2)
            let rightEye = NSRect(x: 9.7, y: 9.5, width: 1.8, height: 2.2)
            NSColor.clear.setFill()
            leftEye.fill(using: .clear)
            rightEye.fill(using: .clear)
            
            return true
        }
        image.isTemplate = true
        return image
    }
    
    // MARK: - 2. Transparent Overlay Window Setup
    private func setupOverlayWindow() {
        let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)
        window = GhostWindow(contentRect: screenFrame)
        
        let hostingView = NSHostingView(rootView: GhostHostView(delegate: self))
        hostingView.frame = screenFrame
        hostingView.autoresizingMask = [.width, .height]
        
        window.contentView = hostingView
        window.makeKeyAndOrderFront(nil)
    }
    
    // MARK: - 3. Position Initialization
    private func setupStateAndPosition() {
        let dockInfo = dockManager.dockInfo
        ghostPosition = CGPoint(x: (dockInfo.minX + dockInfo.maxX) / 2.0, y: dockInfo.topY + 15)
        nextWaveTime = 60.0 + Double.random(in: 0...60.0)
        nextLookAroundTime = 25.0 + Double.random(in: 0...35.0)
    }
    
    // MARK: - 4. Click-to-Wake Global Event Monitor
    private func setupGlobalClickMonitor() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            guard let self = self else { return }
            let mouseLocation = NSEvent.mouseLocation
            
            if self.currentState == .sleeping {
                let ghostBounds = CGRect(
                    x: self.ghostPosition.x - 45,
                    y: self.ghostPosition.y - 10,
                    width: 90,
                    height: 95
                )
                
                if ghostBounds.contains(mouseLocation) {
                    self.wakeUpWithJump()
                }
            }
        }
    }
    
    private func wakeUpWithJump() {
        currentState = .wakingUp
        jumpVelocityY = 12.0
        jumpOffsetY = 0.0
    }
    
    // MARK: - 5. State Machine & Animation Tick Loop
    private func startAnimationLoop() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.updateStateAndPosition()
        }
    }
    
    private func updateStateAndPosition() {
        timeStep += 1.0 / 60.0
        animationTime = timeStep
        
        let dockInfo = dockManager.dockInfo
        let minX = dockInfo.minX
        let maxX = dockInfo.maxX
        let dockTopY = dockInfo.topY
        
        switch currentState {
        case .patrol:
            eyeOffsetX = 0.0
            headTiltAngle = 0.0
            
            // Patrol Glide Motion
            let directionMultiplier: CGFloat = (facingDirection == .right) ? 1.0 : -1.0
            ghostPosition.x += glideSpeed * directionMultiplier
            
            if ghostPosition.x >= maxX {
                ghostPosition.x = maxX
                facingDirection = .left
            } else if ghostPosition.x <= minX {
                ghostPosition.x = minX
                facingDirection = .right
            }
            
            let bobbingY = sin(timeStep * 3.5) * 8.0
            ghostPosition.y = dockTopY + 16.0 + bobbingY
            
            // Check Random Look Around trigger (every 25 to 60 seconds)
            if timeStep >= nextLookAroundTime {
                currentState = .lookingAround
                lookAroundEndTime = timeStep + 3.6
            }
            // Check Random Wave trigger (every 60 to 120 seconds)
            else if timeStep >= nextWaveTime {
                currentState = .waving
                waveEndTime = timeStep + 3.0
            }
            // Check System Idle (3 minutes of inactivity -> Sleep)
            else if idleTracker.isSystemIdle {
                currentState = .sleeping
            }
            
        case .lookingAround:
            // Pause glide motion, continue gentle bobbing
            let bobbingY = sin(timeStep * 3.5) * 4.0
            ghostPosition.y = dockTopY + 16.0 + bobbingY
            
            let lookDuration: Double = 3.6
            let elapsed = lookDuration - (lookAroundEndTime - timeStep)
            
            if elapsed < 1.2 {
                // Phase 1: Look left with curious head tilt
                eyeOffsetX = -4.5
                headTiltAngle = -6.0
            } else if elapsed < 2.4 {
                // Phase 2: Look right with curious head tilt
                eyeOffsetX = 4.5
                headTiltAngle = 6.0
            } else {
                // Phase 3: Center eyes
                eyeOffsetX = 0.0
                headTiltAngle = 0.0
            }
            
            if timeStep >= lookAroundEndTime {
                eyeOffsetX = 0.0
                headTiltAngle = 0.0
                currentState = .patrol
                
                // 40% chance to flip direction after looking around
                if Double.random(in: 0...1) < 0.4 {
                    facingDirection = (facingDirection == .right) ? .left : .right
                }
                
                nextLookAroundTime = timeStep + Double.random(in: 30.0...65.0)
            }
            
        case .waving:
            eyeOffsetX = 0.0
            headTiltAngle = 0.0
            
            let bobbingY = sin(timeStep * 3.5) * 4.0
            ghostPosition.y = dockTopY + 16.0 + bobbingY
            
            if timeStep >= waveEndTime {
                currentState = .patrol
                nextWaveTime = timeStep + Double.random(in: 60.0...120.0)
            }
            
        case .sleeping:
            eyeOffsetX = 0.0
            headTiltAngle = 0.0
            
            let restingY = dockTopY + 4.0
            ghostPosition.y = ghostPosition.y + (restingY - ghostPosition.y) * 0.08
            
        case .wakingUp:
            eyeOffsetX = 0.0
            headTiltAngle = 0.0
            
            jumpOffsetY += jumpVelocityY
            jumpVelocityY -= 0.75
            
            ghostPosition.y = dockTopY + 16.0 + jumpOffsetY
            
            if jumpOffsetY <= 0.0 && jumpVelocityY < 0 {
                jumpOffsetY = 0.0
                jumpVelocityY = 0.0
                currentState = .patrol
                nextWaveTime = timeStep + Double.random(in: 60.0...120.0)
                nextLookAroundTime = timeStep + Double.random(in: 25.0...55.0)
            }
        }
    }
}

/// SwiftUI Hosting Root View observing AppDelegate state
struct GhostHostView: View {
    let delegate: AppDelegate
    
    @State private var state: GhostState = .patrol
    @State private var facing: FacingDirection = .right
    @State private var position: CGPoint = .zero
    @State private var animTime: Double = 0.0
    @State private var eyeOffsetX: CGFloat = 0.0
    @State private var headTiltAngle: Double = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.clear
                
                GhostCanvasView(
                    state: state,
                    facingDirection: facing,
                    animationTime: animTime,
                    eyeOffsetX: eyeOffsetX,
                    headTiltAngle: headTiltAngle
                )
                .position(x: position.x, y: geometry.size.height - position.y)
            }
        }
        .onReceive(delegate.$currentState) { state = $0 }
        .onReceive(delegate.$facingDirection) { facing = $0 }
        .onReceive(delegate.$ghostPosition) { position = $0 }
        .onReceive(delegate.$animationTime) { animTime = $0 }
        .onReceive(delegate.$eyeOffsetX) { eyeOffsetX = $0 }
        .onReceive(delegate.$headTiltAngle) { headTiltAngle = $0 }
        .edgesIgnoringSafeArea(.all)
    }
}
