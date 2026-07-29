import Foundation

/// Defines available desktop companion characters.
enum CompanionType: String, CaseIterable, Identifiable {
    case boo = "Boo (Ghost)"
    case salem = "Salem (Black Cat)"
    case jack = "Jack (Pumpkin)"
    
    var id: String { rawValue }
    
    var name: String {
        switch self {
        case .boo: return "Boo"
        case .salem: return "Salem"
        case .jack: return "Jack"
        }
    }
    
    var emoji: String {
        switch self {
        case .boo: return "👻"
        case .salem: return "🐈‍⬛"
        case .jack: return "🎃"
        }
    }
}
