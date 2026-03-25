import Foundation
import SwiftUI

/// R3: AI-generated dream art — abstract representation of dream symbols and emotions
struct DreamArt: Identifiable, Codable, Equatable {
    let id: UUID
    let dreamId: UUID
    var imageURL: URL?
    var prompt: String
    var emotionalPalette: [String] // e.g. ["Awe", "Freedom", "Nostalgia"]
    var dominantColors: [String] // hex colors
    var style: DreamArtStyle
    var createdAt: Date

    init(
        id: UUID = UUID(),
        dreamId: UUID,
        imageURL: URL? = nil,
        prompt: String,
        emotionalPalette: [String] = [],
        dominantColors: [String] = [],
        style: DreamArtStyle = .abstract,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.dreamId = dreamId
        self.imageURL = imageURL
        self.prompt = prompt
        self.emotionalPalette = emotionalPalette
        self.dominantColors = dominantColors
        self.style = style
        self.createdAt = createdAt
    }

    var gradientColors: [Color] {
        dominantColors.map { Color(hex: $0) }
    }
}

enum DreamArtStyle: String, Codable, CaseIterable, Identifiable {
    case abstract = "abstract"
    case ethereal = "ethereal"
    case cosmic = "cosmic"
    case fluid = "fluid"
    case geometric = "geometric"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .abstract: return "Abstract"
        case .ethereal: return "Ethereal"
        case .cosmic: return "Cosmic"
        case .fluid: return "Fluid"
        case .geometric: return "Geometric"
        }
    }

    var description: String {
        switch self {
        case .abstract: return "Flowing shapes and emotion-driven forms"
        case .ethereal: return "Soft, luminous, otherworldly glow"
        case .cosmic: return "Nebulae, stars, and celestial wonder"
        case .fluid: return "Water-like movements and transitions"
        case .geometric: return "Sacred geometry and fractal patterns"
        }
    }
}
