import SwiftUI

/// R3: Dream Art Generator — creates abstract art from dream symbols and emotional palette
/// Since we can't call an AI image API, this generates beautiful programmatic art
struct DreamArtGenerator {
    let dream: Dream
    let style: DreamArtStyle

    /// Generate the art as SwiftUI shapes
    @ViewBuilder
    func generateArt(in size: CGSize) -> some View {
        switch style {
        case .abstract:
            AbstractDreamArt(dream: dream, size: size)
        case .ethereal:
            EtherealDreamArt(dream: dream, size: size)
        case .cosmic:
            CosmicDreamArt(dream: dream, size: size)
        case .fluid:
            FluidDreamArt(dream: dream, size: size)
        case .geometric:
            GeometricDreamArt(dream: dream, size: size)
        }
    }

    /// Build a prompt string for documentation/storage
    static func buildPrompt(for dream: Dream, style: DreamArtStyle) -> String {
        let emotions = dream.emotionalTags.joined(separator: ", ")
        let symbols = dream.symbols.prefix(5).map { $0.name }.joined(separator: ", ")
        return "A \(style.displayName.lowercased()) dream artwork representing: \(emotions). Symbols: \(symbols). Colors inspired by the dream's emotional palette."
    }

    /// Extract dominant colors from dream
    static func extractColors(from dream: Dream) -> [String] {
        var colors: [String] = []

        // Add mood-based color
        if let mood = dream.mood {
            switch mood {
            case .peaceful: colors.append("34D399")
            case .anxious: colors.append("FBBF24")
            case .exhilarating: colors.append("FCD34D")
            case .confusing: colors.append("C084FC")
            case .dark: colors.append("6B7280")
            case .mysterious: colors.append("5EEAD4")
            case .joyful: colors.append("FB923C")
            case .melancholy: colors.append("60A5FA")
            }
        }

        // Add symbol category colors
        for symbol in dream.symbols.prefix(3) {
            switch symbol.category {
            case .person: colors.append("C084FC")
            case .place: colors.append("60A5FA")
            case .object: colors.append("FCD34D")
            case .emotion: colors.append("5EEAD4")
            }
        }

        // Ensure we have at least 3 colors
        if colors.count < 3 {
            colors.append(contentsOf: ["1A1830", "5EEAD4", "C084FC"])
        }

        return Array(colors.prefix(5))
    }
}

// MARK: - Abstract Art Style

struct AbstractDreamArt: View {
    let dream: Dream
    let size: CGSize

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: DreamArtGenerator.extractColors(from: dream).map { Color(hex: $0).opacity(0.15) },
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Animated blobs using pre-computed shapes
            TimelineView(.animation(minimumInterval: 1.0)) { _ in
                Canvas { context, _ in
                    // Draw simple shapes
                }
            }

            // Static abstract shapes
            ForEach(0..<5, id: \.self) { i in
                BlobShape()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: DreamArtGenerator.extractColors(from: dream)[i % 3]).opacity(0.4),
                                Color(hex: DreamArtGenerator.extractColors(from: dream)[(i + 1) % 3]).opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 150 + CGFloat(i * 20), height: 150 + CGFloat(i * 20))
                    .offset(x: CGFloat(i - 2) * 40, y: CGFloat(i % 3 - 1) * 30)
                    .blur(radius: CGFloat(i) * 2)
            }
        }
    }
}

struct BlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        path.move(to: CGPoint(x: w * 0.5, y: h * 0.1))
        path.addQuadCurve(to: CGPoint(x: w * 0.9, y: h * 0.5), control: CGPoint(x: w, y: h * 0.2))
        path.addQuadCurve(to: CGPoint(x: w * 0.5, y: h * 0.9), control: CGPoint(x: w * 1.1, y: h * 0.8))
        path.addQuadCurve(to: CGPoint(x: w * 0.1, y: h * 0.5), control: CGPoint(x: 0, y: h * 1.1))
        path.addQuadCurve(to: CGPoint(x: w * 0.5, y: h * 0.1), control: CGPoint(x: -w * 0.1, y: h * 0))
        path.closeSubpath()
        return path
    }
}

// MARK: - Ethereal Art Style

struct EtherealDreamArt: View {
    let dream: Dream
    let size: CGSize

    private var colors: [Color] {
        DreamArtGenerator.extractColors(from: dream).map { Color(hex: $0) }
    }

    var body: some View {
        ZStack {
            Color(hex: "0A0A14")

            // Luminous orbs
            ForEach(0..<8, id: \.self) { i in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [colors[i % colors.count].opacity(0.6), colors[i % colors.count].opacity(0)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                        )
                    )
                    .frame(width: 60 + CGFloat(i * 10), height: 60 + CGFloat(i * 10))
                    .offset(
                        x: CGFloat.random(in: -80...80),
                        y: CGFloat.random(in: -60...60)
                    )
                    .blur(radius: CGFloat(i % 3) * 4)
            }

            // Soft center glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [colors[0].opacity(0.3), Color.clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)

            // Aura rays
            ForEach(0..<8, id: \.self) { i in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [colors[i % colors.count].opacity(0.2), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 20, height: size.height * 0.8)
                    .offset(y: -size.height * 0.1)
                    .rotationEffect(.degrees(Double(i) * 45))
            }
        }
    }
}

// MARK: - Cosmic Art Style

struct CosmicDreamArt: View {
    let dream: Dream
    let size: CGSize

    private var colors: [Color] {
        DreamArtGenerator.extractColors(from: dream).map { Color(hex: $0) }
    }

    var body: some View {
        ZStack {
            // Dark space background
            RadialGradient(
                colors: [Color(hex: "12101F"), Color(hex: "0A0A14")],
                center: .center,
                startRadius: 0,
                endRadius: max(size.width, size.height) * 0.7
            )

            // Nebula clouds
            ForEach(0..<3, id: \.self) { i in
                Ellipse()
                    .fill(colors[i % colors.count].opacity(0.25))
                    .frame(width: 160, height: 120)
                    .offset(
                        x: size.width * CGFloat(i) / 4 - size.width / 4,
                        y: sin(Double(i) * 2) * 30
                    )
                    .blur(radius: 20)
            }

            // Stars
            ForEach(0..<30, id: \.self) { i in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...0.8)))
                    .frame(width: CGFloat.random(in: 1...3), height: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...size.width),
                        y: CGFloat.random(in: 0...size.height)
                    )
            }

            // Constellation from symbols
            let symbolCount = min(dream.symbols.count, 5)
            if symbolCount > 0 {
                ForEach(0..<symbolCount, id: \.self) { index in
                    let angle = (2 * .pi / Double(symbolCount)) * Double(index)
                    let radius: CGFloat = 80
                    let centerX = size.width / 2
                    let centerY = size.height / 2
                    let x = centerX + cos(angle) * radius
                    let y = centerY + sin(angle) * radius

                    Circle()
                        .fill(dream.symbols[index].category.color.opacity(0.8))
                        .frame(width: 16, height: 16)
                        .position(x: x, y: y)

                    // Connecting lines (skip first)
                    if index > 0 {
                        let prevAngle = (2 * .pi / Double(symbolCount)) * Double(index - 1)
                        let prevX = centerX + cos(prevAngle) * radius
                        let prevY = centerY + sin(prevAngle) * radius

                        Path { path in
                            path.move(to: CGPoint(x: prevX, y: prevY))
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        .stroke(dream.symbols[index].category.color.opacity(0.4), lineWidth: 1)
                    }
                }
            }

            // Center symbol
            if let first = dream.symbols.first {
                Circle()
                    .fill(first.category.color.opacity(0.6))
                    .frame(width: 24, height: 24)
                    .position(x: size.width / 2, y: size.height / 2)
            }
        }
    }
}

// MARK: - Fluid Art Style

struct FluidDreamArt: View {
    let dream: Dream
    let size: CGSize

    private var colors: [Color] {
        DreamArtGenerator.extractColors(from: dream).map { Color(hex: $0) }
    }

    var body: some View {
        ZStack {
            Color(hex: "0A0A14")

            // Fluid waves
            ForEach(0..<4, id: \.self) { i in
                WaveShape(phase: Double(i) * 0.5)
                    .fill(colors[i % colors.count].opacity(0.3))
                    .frame(height: 150)
                    .offset(y: size.height * CGFloat(i + 1) / 5 - 50)
            }
        }
    }
}

struct WaveShape: Shape {
    var phase: Double

    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))

        let midY = rect.midY
        for x in stride(from: CGFloat.zero, to: rect.width, by: 10) {
            let relativeX = x / rect.width
            let y = midY + sin(relativeX * 4 * .pi + phase) * 20
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()

        return path
    }
}

// MARK: - Geometric Art Style

struct GeometricDreamArt: View {
    let dream: Dream
    let size: CGSize

    private var colors: [Color] {
        DreamArtGenerator.extractColors(from: dream).map { Color(hex: $0) }
    }

    var body: some View {
        ZStack {
            Color(hex: "0A0A14")

            // Flower of life pattern
            ForEach(0..<4, id: \.self) { ring in
                ForEach(0..<(ring == 0 ? 1 : ring * 6), id: \.self) { i in
                    let angle = (2 * .pi / Double(max(1, ring == 0 ? 1 : ring * 6))) * Double(i)
                    let ringRadius = CGFloat(ring) * 30 + 20
                    let centerX = size.width / 2
                    let centerY = size.height / 2
                    let x = centerX + cos(angle) * ringRadius
                    let y = centerY + sin(angle) * ringRadius

                    Circle()
                        .stroke(colors[ring % colors.count].opacity(0.2 + 0.1 * Double(ring)), lineWidth: 1)
                        .frame(width: 30, height: 30)
                        .position(x: x, y: y)
                }
            }

            // Central symbol marker
            if let symbol = dream.symbols.first {
                Circle()
                    .fill(symbol.category.color.opacity(0.6))
                    .frame(width: 24, height: 24)
                    .position(x: size.width / 2, y: size.height / 2)
            }
        }
    }
}

// MARK: - Dream Art View Component

struct DreamArtView: View {
    let dream: Dream
    let style: DreamArtStyle
    let size: CGSize

    var body: some View {
        DreamArtGenerator(dream: dream, style: style)
            .generateArt(in: size)
    }
}
