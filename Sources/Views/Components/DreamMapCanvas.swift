import SwiftUI

struct DreamMapCanvas: View {
    let nodes: [MapNode]
    let edges: [MapEdge]
    let selectedNodeId: UUID?
    let onNodeTap: (UUID) -> Void

    @State private var draggedNodeId: UUID?
    @State private var nodePositions: [UUID: CGPoint] = [:]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Draw edges
                ForEach(edges) { edge in
                    if let sourcePos = positionFor(edge.sourceId),
                       let targetPos = positionFor(edge.targetId) {
                        EdgeView(
                            start: sourcePos,
                            end: targetPos,
                            strength: edge.strength,
                            isHighlighted: isEdgeHighlighted(edge)
                        )
                    }
                }

                // Draw nodes
                ForEach(nodes) { node in
                    NodeView(
                        node: node,
                        isSelected: node.id == selectedNodeId,
                        isHighlighted: isNodeHighlighted(node.id)
                    )
                    .position(positionFor(node.id) ?? node.position)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                draggedNodeId = node.id
                                nodePositions[node.id] = value.location
                            }
                            .onEnded { _ in
                                draggedNodeId = nil
                            }
                    )
                    .onTapGesture {
                        onNodeTap(node.id)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }

    private func positionFor(_ id: UUID) -> CGPoint? {
        if let dragged = draggedNodeId, dragged == id {
            return nodePositions[id]
        }
        return nodes.first { $0.id == id }?.position
    }

    private func isNodeHighlighted(_ nodeId: UUID) -> Bool {
        guard let selectedId = selectedNodeId else { return false }
        if nodeId == selectedId { return true }

        return edges.contains { edge in
            (edge.sourceId == selectedId && edge.targetId == nodeId) ||
            (edge.targetId == selectedId && edge.sourceId == nodeId)
        }
    }

    private func isEdgeHighlighted(_ edge: MapEdge) -> Bool {
        guard let selectedId = selectedNodeId else { return false }
        return edge.sourceId == selectedId || edge.targetId == selectedId
    }
}

struct NodeView: View {
    let node: MapNode
    let isSelected: Bool
    let isHighlighted: Bool

    @State private var isAppearing = false

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Glow effect
                Circle()
                    .fill(node.symbol.category.color.opacity(0.3))
                    .frame(width: nodeSize + 16, height: nodeSize + 16)
                    .blur(radius: isSelected || isHighlighted ? 8 : 4)

                // Main circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                node.symbol.category.color,
                                node.symbol.category.color.opacity(0.6)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: nodeSize / 2
                        )
                    )
                    .frame(width: nodeSize, height: nodeSize)

                // Icon
                Image(systemName: node.symbol.category.icon)
                    .font(.system(size: nodeSize * 0.4))
                    .foregroundColor(.white)
            }

            // Label
            Text(node.symbol.name)
                .font(AppFonts.caption)
                .foregroundColor(isHighlighted || !isSelected ? AppColors.textPrimary : AppColors.textSecondary)
                .lineLimit(1)
        }
        .opacity(isAppearing ? 1 : 0)
        .scaleEffect(isAppearing ? 1 : 0.5)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double.random(in: 0...0.3))) {
                isAppearing = true
            }
        }
    }

    private var nodeSize: CGFloat {
        let baseSize: CGFloat = 32
        let frequencyBonus = CGFloat(min(node.symbol.frequency, 5)) * 4
        return baseSize + frequencyBonus
    }
}

struct EdgeView: View {
    let start: CGPoint
    let end: CGPoint
    let strength: Int
    let isHighlighted: Bool

    var body: some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: end)
        }
        .stroke(
            AppColors.auroraCyan.opacity(isHighlighted ? 0.6 : 0.15),
            style: StrokeStyle(
                lineWidth: isHighlighted ? CGFloat(strength) * 1.5 : CGFloat(strength),
                lineCap: .round
            )
        )
    }
}

#Preview {
    ZStack {
        AppColors.backgroundPrimary.ignoresSafeArea()
        DreamMapCanvas(
            nodes: Symbol.samples.prefix(5).enumerated().map { index, symbol in
                MapNode(
                    symbol: symbol,
                    position: CGPoint(
                        x: CGFloat(100 + index * 60),
                        y: CGFloat(150 + index * 30)
                    )
                )
            },
            edges: [],
            selectedNodeId: nil,
            onNodeTap: { _ in }
        )
    }
}
