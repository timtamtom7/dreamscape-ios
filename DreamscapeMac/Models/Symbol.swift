import Foundation

struct DreamSymbol: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let name: String
    var category: Category
    var occurrenceCount: Int
    var lastAppeared: Date?

    init(id: UUID = UUID(), name: String, category: Category, occurrenceCount: Int = 1, lastAppeared: Date? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.occurrenceCount = occurrenceCount
        self.lastAppeared = lastAppeared
    }

    enum Category: String, Codable, CaseIterable, Identifiable {
        case person = "Person"
        case place = "Place"
        case object = "Object"
        case emotion = "Emotion"
        case animal = "Animal"
        case element = "Element"

        var id: String { rawValue }

        var color: String {
            switch self {
            case .person: return "C084FC"
            case .place: return "60A5FA"
            case .object: return "FCD34D"
            case .emotion: return "5EEAD4"
            case .animal: return "34D399"
            case .element: return "F87171"
            }
        }

        var icon: String {
            switch self {
            case .person: return "person.fill"
            case .place: return "mappin.circle.fill"
            case .object: return "cube.fill"
            case .emotion: return "heart.fill"
            case .animal: return "pawprint.fill"
            case .element: return "flame.fill"
            }
        }
    }
}

extension DreamSymbol {
    static let samples: [DreamSymbol] = [
        DreamSymbol(name: "ocean", category: .element, occurrenceCount: 12, lastAppeared: Date()),
        DreamSymbol(name: "flight", category: .object, occurrenceCount: 8, lastAppeared: Date().addingTimeInterval(-86400)),
        DreamSymbol(name: "moon", category: .object, occurrenceCount: 15, lastAppeared: Date()),
        DreamSymbol(name: "library", category: .place, occurrenceCount: 5, lastAppeared: Date().addingTimeInterval(-172800)),
        DreamSymbol(name: "water", category: .element, occurrenceCount: 20, lastAppeared: Date()),
        DreamSymbol(name: "stars", category: .object, occurrenceCount: 18, lastAppeared: Date()),
        DreamSymbol(name: "house", category: .place, occurrenceCount: 10, lastAppeared: Date().addingTimeInterval(-259200)),
        DreamSymbol(name: "forest", category: .place, occurrenceCount: 7, lastAppeared: Date().addingTimeInterval(-345600)),
        DreamSymbol(name: "bird", category: .animal, occurrenceCount: 4, lastAppeared: Date().addingTimeInterval(-432000)),
        DreamSymbol(name: "freedom", category: .emotion, occurrenceCount: 6, lastAppeared: Date()),
    ]
}
