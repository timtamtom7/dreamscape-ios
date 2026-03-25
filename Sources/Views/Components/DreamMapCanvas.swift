import SwiftUI

struct DreamMapCanvas: View {
    let nodes: [MapNode]
    let edges: [MapEdge]
    let selectedNodeId: UUID?
    let onNodeTap: (UUID) -> Void

    @State private var animatedPositions: [UUID: CGPoint] = [:]
    @State private var nodeVelocities: [UUID: CGPoint] = [:]
    @State private var timer: Timer?
    @State private var isNodeDragging = false  // Pause physics during node drag to prevent jitter

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Draw edges
                ForEach(edges) { edge in
                    if let sourcePos = animatedPositions[edge.sourceId],
                       let targetPos = animatedPositions[edge.targetId] {
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
                    .position(animatedPositions[node.id] ?? node.position)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isNodeDragging = true
                                animatedPositions[node.id] = value.location
                            }
                            .onEnded { _ in
                                isNodeDragging = false
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                    settleNode(node.id)
                                }
                            }
                    )
                    .onTapGesture {
                        onNodeTap(node.id)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear {
            initializePositions()
            startSimulation()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .onChange(of: nodes.count) { _, _ in
            initializePositions()
        }
    }

    private func initializePositions() {
        for node in nodes {
            if animatedPositions[node.id] == nil {
                animatedPositions[node.id] = node.position
            }
        }
    }

    private func settleNode(_ id: UUID) {
        guard animatedPositions[id] != nil else { return }
        let center = CGPoint(x: 200, y: 300)
        let radius: CGFloat = 150
        let index = nodes.firstIndex(where: { $0.id == id }) ?? 0
        let angle = (2 * .pi / CGFloat(max(nodes.count, 1))) * CGFloat(index)
        let target = CGPoint(
            x: center.x + radius * cos(angle),
            y: center.y + radius * sin(angle)
        )
        animatedPositions[id] = target
    }

    private func startSimulation() {
        timer?.invalidate()
        // Use Timer for smooth 60fps physics
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
            Task { @MainActor in
                self.updatePhysicsIfAllowed()
            }
        }
    }
    
    @MainActor
    private func updatePhysicsIfAllowed() {
        guard !isNodeDragging else { return }
        updatePhysics()
    }

    private func updatePhysics() {
        guard nodes.count > 1 else { return }

        var forces: [UUID: CGPoint] = [:]

        // Repulsion between all nodes
        for i in nodes {
            forces[i.id] = .zero
            for j in nodes where j.id != i.id {
                guard let posI = animatedPositions[i.id],
                      let posJ = animatedPositions[j.id] else { continue }

                let delta = CGPoint(x: posI.x - posJ.x, y: posI.y - posJ.y)
                let distance = max(sqrt(delta.x * delta.x + delta.y * delta.y), 1)
                let repulsion: CGFloat = 2000 / (distance * distance)
                let normalized = CGPoint(x: delta.x / distance, y: delta.y / distance)
                forces[i.id] = CGPoint(
                    x: forces[i.id]!.x + normalized.x * repulsion,
                    y: forces[i.id]!.y + normalized.y * repulsion
                )
            }
        }

        // Attraction along edges
        for edge in edges {
            guard let posSource = animatedPositions[edge.sourceId],
                  let posTarget = animatedPositions[edge.targetId] else { continue }

            let delta = CGPoint(x: posTarget.x - posSource.x, y: posTarget.y - posSource.y)
            let distance = max(sqrt(delta.x * delta.x + delta.y * delta.y), 1)
            let attraction: CGFloat = 0.05 * CGFloat(edge.strength)
            let normalized = CGPoint(x: delta.x / distance, y: delta.y / distance)

            forces[edge.sourceId] = CGPoint(
                x: forces[edge.sourceId]!.x + normalized.x * attraction,
                y: forces[edge.sourceId]!.y + normalized.y * attraction
            )
            forces[edge.targetId] = CGPoint(
                x: forces[edge.targetId]!.x - normalized.x * attraction,
                y: forces[edge.targetId]!.y - normalized.y * attraction
            )
        }

        // Apply forces with spring damping
        for node in nodes {
            guard let current = animatedPositions[node.id],
                  let force = forces[node.id] else { continue }

            let velocity = CGPoint(
                x: (nodeVelocities[node.id]?.x ?? 0) * 0.8 + force.x,
                y: (nodeVelocities[node.id]?.y ?? 0) * 0.8 + force.y
            )
            nodeVelocities[node.id] = velocity

            let newPosition = CGPoint(
                x: current.x + velocity.x,
                y: current.y + velocity.y
            )
            animatedPositions[node.id] = newPosition
        }
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
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Outer glow
                Circle()
                    .fill(node.symbol.category.color.opacity(0.2))
                    .frame(width: nodeSize + 20, height: nodeSize + 20)
                    .blur(radius: isSelected || isHighlighted ? 12 : 6)
                    .scaleEffect(isSelected || isHighlighted ? pulseScale : 1.0)

                // Mid glow
                Circle()
                    .fill(node.symbol.category.color.opacity(0.25))
                    .frame(width: nodeSize + 12, height: nodeSize + 12)

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
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )

                // Icon
                Image(systemName: node.symbol.category.icon)
                    .font(.system(size: nodeSize * 0.4, weight: .medium))
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

            // Pulse animation for selected/highlighted nodes
            if isSelected || isHighlighted {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulseScale = 1.15
                }
            }
        }
    }

    private var nodeSize: CGFloat {
        let baseSize: CGFloat = 32
        let frequencyBonus = CGFloat(min(node.symbol.frequency, 5)) * 4
        let selectedBonus: CGFloat = (isSelected || isHighlighted) ? 8 : 0
        return baseSize + frequencyBonus + selectedBonus
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
