import Foundation
import SwiftUI

enum SymbolCategory: String, Codable, CaseIterable, Identifiable {
    case person
    case place
    case object
    case emotion

    var id: Self { self }

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

    // R2: Enhanced fields
    var emotionalTag: String?
    var rarityScore: Double // 0.0 (common) to 1.0 (rare)

    init(
        id: UUID = UUID(),
        name: String,
        category: SymbolCategory,
        frequency: Int = 1,
        lastSeen: Date = Date(),
        emotionalTag: String? = nil,
        rarityScore: Double = 0.5
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.frequency = frequency
        self.lastSeen = lastSeen
        self.emotionalTag = emotionalTag
        self.rarityScore = rarityScore
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Symbol, rhs: Symbol) -> Bool {
        lhs.id == rhs.id
    }

    /// Rarity level based on score
    var rarityLevel: RarityLevel {
        switch rarityScore {
        case 0..<0.25: return .common
        case 0.25..<0.6: return .uncommon
        case 0.6..<0.85: return .rare
        default: return .veryRare
        }
    }

    /// Symbol clusters — groups of related symbols
    static let fearCluster = ["water", "drowning", "ocean", "sea", "tsunami", "flood", "whirlpool", "storm"]
    static let freedomCluster = ["flying", "flight", "soaring", "bird", "wing", "jump", "leap", "falling"]
    static let pursuitCluster = ["chase", "running", "flee", "monster", "beast", "creature"]
    static let waterCluster = ["water", "ocean", "sea", "river", "lake", "swimming", "diving", "rain"]

    /// Check if this symbol belongs to a cluster
    func clusterName(for symbols: [Symbol]) -> String? {
        let names = symbols.map { $0.name.lowercased() }

        let clusters: [(name: String, members: [String])] = [
            ("Fear", Symbol.fearCluster),
            ("Freedom", Symbol.freedomCluster),
            ("Pursuit", Symbol.pursuitCluster),
            ("Water", Symbol.waterCluster)
        ]

        for (name, members) in clusters {
            let matchCount = members.filter { membersItem in
                names.contains { $0.contains(membersItem) || membersItem.contains($0) }
            }.count
            if matchCount >= 2 {
                return name
            }
        }
        return nil
    }
}

enum RarityLevel: String {
    case common = "Common"
    case uncommon = "Uncommon"
    case rare = "Rare"
    case veryRare = "Very Rare"

    var color: Color {
        switch self {
        case .common: return AppColors.textMuted
        case .uncommon: return AppColors.auroraCyan
        case .rare: return AppColors.nebulaPink
        case .veryRare: return AppColors.starGold
        }
    }

    var icon: String {
        switch self {
        case .common: return "circle.fill"
        case .uncommon: return "circle.lefthalf.filled"
        case .rare: return "star.fill"
        case .veryRare: return "star.circle.fill"
        }
    }
}

/// Tracks a symbol's occurrence in a dream for the diary
struct SymbolDiaryEntry: Identifiable, Codable {
    let id: UUID
    let symbolId: UUID
    let dreamId: UUID
    let date: Date
    var emotionalTag: String?

    init(symbolId: UUID, dreamId: UUID, date: Date = Date(), emotionalTag: String? = nil) {
        self.id = UUID()
        self.symbolId = symbolId
        self.dreamId = dreamId
        self.date = date
        self.emotionalTag = emotionalTag
    }
}

extension Symbol {
    static let samples: [Symbol] = [
        Symbol(name: "Ocean", category: .place, frequency: 5, emotionalTag: "Awe", rarityScore: 0.3),
        Symbol(name: "Flying", category: .emotion, frequency: 3, emotionalTag: "Freedom", rarityScore: 0.4),
        Symbol(name: "Dolphin", category: .object, frequency: 2, emotionalTag: "Joy", rarityScore: 0.7),
        Symbol(name: "Island", category: .place, frequency: 4, emotionalTag: "Hope", rarityScore: 0.5),
        Symbol(name: "Mother", category: .person, frequency: 6, emotionalTag: "Nostalgia", rarityScore: 0.2),
        Symbol(name: "Childhood Home", category: .place, frequency: 3, emotionalTag: "Nostalgia", rarityScore: 0.35),
        Symbol(name: "Waterfall", category: .place, frequency: 2, emotionalTag: "Awe", rarityScore: 0.6),
        Symbol(name: "Freedom", category: .emotion, frequency: 4, emotionalTag: "Liberation", rarityScore: 0.45),
        Symbol(name: "Mirror", category: .object, frequency: 3, emotionalTag: "Confusion", rarityScore: 0.55),
        Symbol(name: "Stranger", category: .person, frequency: 7, emotionalTag: "Anxiety", rarityScore: 0.15)
    ]
}
