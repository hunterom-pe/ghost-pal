import Foundation
import CoreGraphics

/// Defines the ghost's current state in the state machine.
enum GhostState: String, CustomStringConvertible {
    case patrol = "Patrolling"
    case waving = "Waving"
    case sleeping = "Sleeping"
    case wakingUp = "Waking Up!"
    case lookingAround = "Looking Around"
    case staring = "Staring at Cursor"
    case flipping = "Acrobatic Flip!"
    
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
    
    var isLookingAround: Bool {
        return self == .lookingAround
    }
    
    var isStaring: Bool {
        return self == .staring
    }
    
    var isFlipping: Bool {
        return self == .flipping
    }
}

/// Facing direction for sprite flip
enum FacingDirection {
    case left
    case right
}
