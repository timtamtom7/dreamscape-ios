import Foundation
import SwiftUI

// MARK: - Dream Incubation

struct DreamIncubation: Identifiable, Codable {
    let id: UUID
    var intention: String
    var aiRefinedIntention: String?
    var createdAt: Date
    var targetDate: Date
    var isCompleted: Bool
    var relatedDreamId: UUID?
    var notes: String?
    var wasSuccessful: Bool?

    init(
        id: UUID = UUID(),
        intention: String,
        aiRefinedIntention: String? = nil,
        createdAt: Date = Date(),
        targetDate: Date? = nil,
        isCompleted: Bool = false,
        relatedDreamId: UUID? = nil,
        notes: String? = nil,
        wasSuccessful: Bool? = nil
    ) {
        self.id = id
        self.intention = intention
        self.aiRefinedIntention = aiRefinedIntention
        self.createdAt = createdAt
        self.targetDate = targetDate ?? Calendar.current.startOfDay(for: createdAt)
        self.isCompleted = isCompleted
        self.relatedDreamId = relatedDreamId
        self.notes = notes
        self.wasSuccessful = wasSuccessful
    }
}

// MARK: - Incubation Store

@MainActor
final class IncubationStore: ObservableObject {
    static let shared = IncubationStore()

    private let key = "dream_incubations"

    @Published var incubations: [DreamIncubation] = []

    var activeIncubations: [DreamIncubation] {
        incubations.filter { !$0.isCompleted }
    }

    var completedIncubations: [DreamIncubation] {
        incubations.filter { $0.isCompleted }
    }

    var successRate: Double {
        let completed = completedIncubations.filter { $0.wasSuccessful != nil }
        guard !completed.isEmpty else { return 0 }
        let successes = completed.filter { $0.wasSuccessful == true }.count
        return Double(successes) / Double(completed.count) * 100
    }

    init() {
        load()
    }

    func add(_ incubation: DreamIncubation) {
        incubations.insert(incubation, at: 0)
        save()
    }

    func update(_ incubation: DreamIncubation) {
        if let index = incubations.firstIndex(where: { $0.id == incubation.id }) {
            incubations[index] = incubation
            save()
        }
    }

    func markCompleted(incubationId: UUID, relatedDreamId: UUID?, wasSuccessful: Bool, notes: String?) {
        if let index = incubations.firstIndex(where: { $0.id == incubationId }) {
            incubations[index].isCompleted = true
            incubations[index].relatedDreamId = relatedDreamId
            incubations[index].wasSuccessful = wasSuccessful
            incubations[index].notes = notes
            save()
        }
    }

    func delete(_ incubation: DreamIncubation) {
        incubations.removeAll { $0.id == incubation.id }
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([DreamIncubation].self, from: data) else {
            return
        }
        incubations = decoded
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(incubations) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}

// MARK: - Personal Dream Dictionary

struct PersonalSymbolMeaning: Identifiable, Codable {
    let id: UUID
    var symbolName: String
    var meaning: String
    var examples: [String]
    var updatedAt: Date
    var frequency: Int

    init(id: UUID = UUID(), symbolName: String, meaning: String, examples: [String] = [], frequency: Int = 1) {
        self.id = id
        self.symbolName = symbolName
        self.meaning = meaning
        self.examples = examples
        self.updatedAt = Date()
        self.frequency = frequency
    }
}

struct SymbolEvolutionEvent: Identifiable, Codable {
    let id: UUID
    let symbolName: String
    let eventDate: Date
    var previousMeaning: String?
    var newMeaning: String
    var triggerDreamId: UUID?
    var note: String?

    init(id: UUID = UUID(), symbolName: String, eventDate: Date = Date(), previousMeaning: String? = nil, newMeaning: String, triggerDreamId: UUID? = nil, note: String? = nil) {
        self.id = id
        self.symbolName = symbolName
        self.eventDate = eventDate
        self.previousMeaning = previousMeaning
        self.newMeaning = newMeaning
        self.triggerDreamId = triggerDreamId
        self.note = note
    }
}

@MainActor
final class DreamDictionaryStore: ObservableObject {
    static let shared = DreamDictionaryStore()

    private let meaningsKey = "personal_symbol_meanings"
    private let evolutionKey = "symbol_evolution_events"

    @Published var symbolMeanings: [String: PersonalSymbolMeaning] = [:]
    @Published var evolutionEvents: [SymbolEvolutionEvent] = []

    var allSymbols: [PersonalSymbolMeaning] {
        Array(symbolMeanings.values).sorted { $0.symbolName < $1.symbolName }
    }

    var recentlyChanged: [SymbolEvolutionEvent] {
        Array(evolutionEvents.prefix(10))
    }

    init() {
        load()
    }

    func meaning(for symbolName: String) -> PersonalSymbolMeaning? {
        symbolMeanings[symbolName.lowercased()]
    }

    func setMeaning(_ meaning: PersonalSymbolMeaning) {
        let key = meaning.symbolName.lowercased()
        let previous = symbolMeanings[key]
        symbolMeanings[key] = meaning

        // Record evolution if meaning changed
        if let prev = previous, prev.meaning != meaning.meaning {
            let event = SymbolEvolutionEvent(
                symbolName: meaning.symbolName,
                previousMeaning: prev.meaning,
                newMeaning: meaning.meaning
            )
            evolutionEvents.insert(event, at: 0)
        }

        save()
    }

    func incrementFrequency(for symbolName: String) {
        let key = symbolName.lowercased()
        if var meaning = symbolMeanings[key] {
            meaning.frequency += 1
            meaning.updatedAt = Date()
            symbolMeanings[key] = meaning
            save()
        }
    }

    func addExample(_ example: String, to symbolName: String) {
        let key = symbolName.lowercased()
        if var meaning = symbolMeanings[key] {
            meaning.examples.append(example)
            meaning.updatedAt = Date()
            symbolMeanings[key] = meaning
            save()
        } else {
            let newMeaning = PersonalSymbolMeaning(
                symbolName: symbolName,
                meaning: "",
                examples: [example]
            )
            symbolMeanings[key] = newMeaning
            save()
        }
    }

    func evolutionHistory(for symbolName: String) -> [SymbolEvolutionEvent] {
        evolutionEvents.filter { $0.symbolName.lowercased() == symbolName.lowercased() }
    }

    private func load() {
        if let meaningsData = UserDefaults.standard.data(forKey: meaningsKey),
           let meanings = try? JSONDecoder().decode([String: PersonalSymbolMeaning].self, from: meaningsData) {
            symbolMeanings = meanings
        }

        if let eventsData = UserDefaults.standard.data(forKey: evolutionKey),
           let events = try? JSONDecoder().decode([SymbolEvolutionEvent].self, from: eventsData) {
            evolutionEvents = events
        }
    }

    private func save() {
        if let meaningsData = try? JSONEncoder().encode(symbolMeanings) {
            UserDefaults.standard.set(meaningsData, forKey: meaningsKey)
        }
        if let eventsData = try? JSONEncoder().encode(evolutionEvents) {
            UserDefaults.standard.set(eventsData, forKey: evolutionKey)
        }
    }
}
