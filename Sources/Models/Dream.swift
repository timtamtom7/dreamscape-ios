import Foundation
import SwiftUI

// MARK: - Mood Tags

enum MoodTag: String, Codable, CaseIterable, Identifiable {
    case peaceful
    case anxious
    case exhilarating
    case confusing
    case dark
    case mysterious
    case joyful
    case melancholy

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .peaceful: return "leaf.fill"
        case .anxious: return "bolt.fill"
        case .exhilarating: return "star.fill"
        case .confusing: return "questionmark.circle.fill"
        case .dark: return "moon.fill"
        case .mysterious: return "sparkles"
        case .joyful: return "sun.max.fill"
        case .melancholy: return "cloud.rain.fill"
        }
    }

    var color: Color {
        switch self {
        case .peaceful: return AppColors.success
        case .anxious: return AppColors.warning
        case .exhilarating: return AppColors.starGold
        case .confusing: return AppColors.nebulaPink
        case .dark: return AppColors.error
        case .mysterious: return AppColors.auroraCyan
        case .joyful: return AppColors.starGold
        case .melancholy: return Color(hex: "60A5FA")
        }
    }
}

// MARK: - Dream Model

struct Dream: Identifiable, Codable, Equatable {
    let id: UUID
    var content: String
    var summary: String
    var symbols: [Symbol]
    var createdAt: Date
    var updatedAt: Date

    // R2: Enhanced fields
    var mood: MoodTag?
    var isLucid: Bool
    var recurringVariantId: UUID?
    var attachedPhotoURL: URL?
    var emotionalTags: [String]

    init(
        id: UUID = UUID(),
        content: String,
        summary: String = "",
        symbols: [Symbol] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        mood: MoodTag? = nil,
        isLucid: Bool = false,
        recurringVariantId: UUID? = nil,
        attachedPhotoURL: URL? = nil,
        emotionalTags: [String] = []
    ) {
        self.id = id
        self.content = content
        self.summary = summary
        self.symbols = symbols
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.mood = mood
        self.isLucid = isLucid
        self.recurringVariantId = recurringVariantId
        self.attachedPhotoURL = attachedPhotoURL
        self.emotionalTags = emotionalTags
    }

    /// Returns the number of times this dream's recurring group has appeared
    func recurringCount(in allDreams: [Dream]) -> Int {
        guard let variantId = recurringVariantId else { return 1 }
        return allDreams.filter { $0.recurringVariantId == variantId }.count
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }

    var shortFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: createdAt)
    }
}

extension Dream {
    static let sample = Dream(
        content: "I was flying over a vast ocean at sunset. The water was crystal clear and I could see massive underwater cities below. A friendly dolphin appeared and guided me toward a glowing island.",
        summary: "A dream of flight over an ocean revealing hidden underwater cities, guided by a dolphin toward a mysterious glowing island.",
        symbols: [
            Symbol(name: "Ocean", category: .place, frequency: 1, emotionalTag: "Awe"),
            Symbol(name: "Flying", category: .emotion, frequency: 1, emotionalTag: "Freedom"),
            Symbol(name: "Dolphin", category: .object, frequency: 1, emotionalTag: "Joy"),
            Symbol(name: "Island", category: .place, frequency: 1, emotionalTag: "Hope")
        ],
        mood: .exhilarating,
        isLucid: false
    )

    static let sampleLucid = Dream(
        content: "I realized I was dreaming while standing in my childhood home. The living room stretched impossibly far, and floating candles lit the hallway. I knew I could fly if I wanted to.",
        summary: "A lucid dream in a distorted childhood home with floating candles.",
        symbols: [
            Symbol(name: "Childhood Home", category: .place, frequency: 3, emotionalTag: "Nostalgia"),
            Symbol(name: "Flying", category: .emotion, frequency: 5, emotionalTag: "Freedom"),
            Symbol(name: "Candles", category: .object, frequency: 2, emotionalTag: "Mystery")
        ],
        mood: .peaceful,
        isLucid: true
    )
}
