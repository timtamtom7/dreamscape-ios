import Foundation
import SwiftUI
import Combine

struct MapNode: Identifiable {
    let id: UUID
    let symbol: Symbol
    var position: CGPoint
    var velocity: CGPoint

    init(symbol: Symbol, position: CGPoint = .zero) {
        self.id = symbol.id
        self.symbol = symbol
        self.position = position
        self.velocity = .zero
    }
}

struct MapEdge: Identifiable {
    let id: UUID
    let sourceId: UUID
    let targetId: UUID
    var strength: Int

    init(sourceId: UUID, targetId: UUID, strength: Int = 1) {
        self.id = UUID()
        self.sourceId = sourceId
        self.targetId = targetId
        self.strength = strength
    }
}

enum MapTimeFilter: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case allTime = "All Time"
}

@MainActor
final class DreamMapViewModel: ObservableObject {
    @Published var nodes: [MapNode] = []
    @Published var edges: [MapEdge] = []
    @Published var selectedNodeId: UUID?
    @Published var timeFilter: MapTimeFilter = .allTime
    @Published var isLoading = false

    private let databaseService = DatabaseService.shared
    private var dreams: [Dream] = []

    init() {
        loadData()
    }

    func loadData() {
        isLoading = true

        do {
            dreams = try databaseService.fetchAllDreams()
            buildGraph()
        } catch {
            print("Error loading data: \(error)")
        }

        isLoading = false
    }

    func setTimeFilter(_ filter: MapTimeFilter) {
        timeFilter = filter
        buildGraph()
    }

    private func buildGraph() {
        let filteredDreams = filterDreams()
        let allSymbols = filteredDreams.flatMap { $0.symbols }

        // Count symbol frequencies
        var symbolCounts: [String: (symbol: Symbol, count: Int)] = [:]
        for symbol in allSymbols {
            let key = symbol.name.lowercased()
            if let existing = symbolCounts[key] {
                symbolCounts[key] = (existing.symbol, existing.count + 1)
            } else {
                symbolCounts[key] = (symbol, 1)
            }
        }

        // Create nodes
        let center = CGPoint(x: 200, y: 300)
        let radius: CGFloat = 150

        nodes = symbolCounts.values.enumerated().map { index, value in
            let angle = (2 * .pi / CGFloat(symbolCounts.count)) * CGFloat(index)
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)

            var symbol = value.symbol
            symbol = Symbol(
                id: symbol.id,
                name: symbol.name,
                category: symbol.category,
                frequency: value.count,
                lastSeen: symbol.lastSeen
            )

            return MapNode(symbol: symbol, position: CGPoint(x: x, y: y))
        }

        // Create edges between symbols that appear in the same dream
        var edgeMap: [String: MapEdge] = [:]

        for dream in filteredDreams {
            let dreamSymbols = dream.symbols
            for i in 0..<dreamSymbols.count {
                for j in (i+1)..<dreamSymbols.count {
                    let id1 = dreamSymbols[i].id
                    let id2 = dreamSymbols[j].id
                    let key = [id1.uuidString, id2.uuidString].sorted().joined(separator: "-")

                    if let existing = edgeMap[key] {
                        edgeMap[key] = MapEdge(sourceId: existing.sourceId, targetId: existing.targetId, strength: existing.strength + 1)
                    } else {
                        edgeMap[key] = MapEdge(sourceId: id1, targetId: id2, strength: 1)
                    }
                }
            }
        }

        edges = Array(edgeMap.values)
    }

    private func filterDreams() -> [Dream] {
        let calendar = Calendar.current
        let now = Date()

        switch timeFilter {
        case .week:
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return dreams.filter { $0.createdAt >= weekAgo }
        case .month:
            let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return dreams.filter { $0.createdAt >= monthAgo }
        case .allTime:
            return dreams
        }
    }

    func selectNode(_ nodeId: UUID?) {
        selectedNodeId = nodeId
    }

    func connectedNodeIds(for nodeId: UUID) -> Set<UUID> {
        var connected = Set<UUID>()
        for edge in edges {
            if edge.sourceId == nodeId {
                connected.insert(edge.targetId)
            } else if edge.targetId == nodeId {
                connected.insert(edge.sourceId)
            }
        }
        return connected
    }
}
