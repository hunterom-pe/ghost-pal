import Foundation
import CoreGraphics

/// Defines the ghost's current state in the state machine.
enum GhostState: String, CustomStringConvertible {
    case patrol = "Patrolling"
    case waving = "Waving"
    case sleeping = "Sleeping"
    case wakingUp = "Waking Up!"
    
    var description: String {
        return self.rawValue
    }
    
    var isSleeping: Bool {
        return self == .sleeping
    }
    
    var isWaving: Bool {
        return self == .waving
    }
    
    var isPatrolling: Bool {
        return self == .patrol
    }
}

/// Facing direction for sprite flip
enum FacingDirection {
    case left
    case right
}
