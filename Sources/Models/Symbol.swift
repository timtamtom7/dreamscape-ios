import Foundation
import SwiftUI

enum SymbolCategory: String, Codable, CaseIterable {
    case person
    case place
    case object
    case emotion

    var displayName: String {
        switch self {
        case .person: return "Person"
        case .place: return "Place"
        case .object: return "Object"
        case .emotion: return "Emotion"
        }
    }

    var color: Color {
        switch self {
        case .person: return AppColors.nebulaPink
        case .place: return Color(hex: "60A5FA")
        case .object: return AppColors.starGold
        case .emotion: return AppColors.auroraCyan
        }
    }

    var icon: String {
        switch self {
        case .person: return "person.fill"
        case .place: return "mappin.and.ellipse"
        case .object: return "cube.fill"
        case .emotion: return "heart.fill"
        }
    }
}

struct Symbol: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var category: SymbolCategory
    var frequency: Int
    var lastSeen: Date

    init(
        id: UUID = UUID(),
        name: String,
        category: SymbolCategory,
        frequency: Int = 1,
        lastSeen: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.frequency = frequency
        self.lastSeen = lastSeen
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Symbol, rhs: Symbol) -> Bool {
        lhs.id == rhs.id
    }
}

extension Symbol {
    static let samples: [Symbol] = [
        Symbol(name: "Ocean", category: .place, frequency: 5),
        Symbol(name: "Flying", category: .emotion, frequency: 3),
        Symbol(name: "Dolphin", category: .object, frequency: 2),
        Symbol(name: "Island", category: .place, frequency: 4),
        Symbol(name: "Mother", category: .person, frequency: 6),
        Symbol(name: "Childhood Home", category: .place, frequency: 3),
        Symbol(name: "Waterfall", category: .place, frequency: 2),
        Symbol(name: "Freedom", category: .emotion, frequency: 4),
        Symbol(name: "Mirror", category: .object, frequency: 3),
        Symbol(name: "Stranger", category: .person, frequency: 7)
    ]
}
