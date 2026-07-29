import SwiftUI

@main
struct GhostPalApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // App runs cleanly in background without creating standard windows
        Settings {
            EmptyView()
        }
    }
}
