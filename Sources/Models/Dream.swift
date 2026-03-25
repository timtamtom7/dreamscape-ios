import Foundation

struct Dream: Identifiable, Codable, Equatable {
    let id: UUID
    var content: String
    var summary: String
    var symbols: [Symbol]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        content: String,
        summary: String = "",
        symbols: [Symbol] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.summary = summary
        self.symbols = symbols
        self.createdAt = createdAt
        self.updatedAt = updatedAt
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
            Symbol(name: "Ocean", category: .place, frequency: 1),
            Symbol(name: "Flying", category: .emotion, frequency: 1),
            Symbol(name: "Dolphin", category: .object, frequency: 1),
            Symbol(name: "Island", category: .place, frequency: 1)
        ]
    )
}
