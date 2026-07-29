import Foundation
import CoreGraphics

/// Monitors system-wide idle time to transition ghost to sleeping state.
class IdleTracker {
    /// Inactivity threshold in seconds before sleeping (3 minutes = 180 seconds).
    let sleepThreshold: TimeInterval = 180.0
    
    /// Returns the number of seconds since user last pressed a key or moved mouse.
    var systemIdleSeconds: TimeInterval {
        let anyEventType = CGEventType(rawValue: ~0)!
        let seconds = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: anyEventType)
        return TimeInterval(seconds)
    }
    
    /// Returns true if the user has been inactive for longer than the sleep threshold.
    var isSystemIdle: Bool {
        return systemIdleSeconds >= sleepThreshold
    }
}
