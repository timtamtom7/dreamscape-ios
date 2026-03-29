import SwiftUI

struct StarFieldBackground: View {
    @State private var stars: [(id: Int, x: CGFloat, y: CGFloat, opacity: Double, size: CGFloat)] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Theme.deepVoid
                    .ignoresSafeArea()

                ForEach(stars, id: \.id) { star in
                    Circle()
                        .fill(Color.white)
                        .frame(width: star.size, height: star.size)
                        .opacity(star.opacity)
                        .position(x: star.x, y: star.y)
                        .animation(
                            .easeInOut(duration: Double.random(in: 2...4))
                                .repeatForever(autoreverses: true),
                            value: star.opacity
                        )
                }
            }
            .onAppear {
                generateStars(in: geometry.size)
            }
        }
    }

    private func generateStars(in size: CGSize) {
        stars = (0..<120).map { i in
            let x = CGFloat.random(in: 0...size.width)
            let y = CGFloat.random(in: 0...size.height)
            let baseOpacity = Double.random(in: 0.1...0.6)
            return (
                id: i,
                x: x,
                y: y,
                opacity: baseOpacity,
                size: CGFloat.random(in: 1...2.5)
            )
        }
    }
}

struct StarFieldView: View {
    var body: some View {
        StarFieldBackground()
            .blendMode(.screen)
            .opacity(0.6)
    }
}
