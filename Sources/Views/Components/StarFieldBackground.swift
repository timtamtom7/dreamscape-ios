import SwiftUI

struct StarFieldBackground: View {
    let starCount: Int

    @State private var stars: [Star] = []

    struct Star: Identifiable, Equatable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let opacity: Double
        let animationDuration: Double
        let animationDelay: Double
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base gradient background
                LinearGradient(
                    colors: [
                        AppColors.backgroundPrimary,
                        Color(hex: "0D0B1E"),
                        AppColors.backgroundSecondary
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Stars with TimelineView for proper animation
                TimelineView(.animation(minimumInterval: 0.5)) { timeline in
                    ForEach(stars) { star in
                        let time = timeline.date.timeIntervalSinceReferenceDate
                        let animatedOpacity = 0.3 + 0.4 * sin(time * (1 + star.animationDelay) + star.animationDuration)

                        Circle()
                            .fill(Color.white)
                            .frame(width: star.size, height: star.size)
                            .position(x: star.x * geometry.size.width, y: star.y * geometry.size.height)
                            .opacity(animatedOpacity)
                    }
                }

                // Subtle nebula overlay
                RadialGradient(
                    colors: [
                        AppColors.nebulaPink.opacity(0.05),
                        Color.clear
                    ],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: geometry.size.width * 0.8
                )

                RadialGradient(
                    colors: [
                        AppColors.auroraCyan.opacity(0.03),
                        Color.clear
                    ],
                    center: .bottomTrailing,
                    startRadius: 0,
                    endRadius: geometry.size.width * 0.6
                )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            generateStars()
        }
    }

    private func generateStars() {
        stars = (0..<starCount).map { _ in
            Star(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 1...2.5),
                opacity: Double.random(in: 0.3...0.8),
                animationDuration: Double.random(in: 2...4),
                animationDelay: Double.random(in: 0...2)
            )
        }
    }
}

struct AnimatedStarField: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                // Draw a simple star field
                let starPositions = [
                    CGPoint(x: size.width * 0.1, y: size.height * 0.2),
                    CGPoint(x: size.width * 0.3, y: size.height * 0.1),
                    CGPoint(x: size.width * 0.5, y: size.height * 0.3),
                    CGPoint(x: size.width * 0.7, y: size.height * 0.15),
                    CGPoint(x: size.width * 0.9, y: size.height * 0.25),
                    CGPoint(x: size.width * 0.15, y: size.height * 0.5),
                    CGPoint(x: size.width * 0.85, y: size.height * 0.55),
                    CGPoint(x: size.width * 0.25, y: size.height * 0.7),
                    CGPoint(x: size.width * 0.6, y: size.height * 0.8),
                    CGPoint(x: size.width * 0.45, y: size.height * 0.9)
                ]

                for (index, position) in starPositions.enumerated() {
                    let time = timeline.date.timeIntervalSinceReferenceDate
                    let opacity = 0.3 + 0.4 * sin(time * (1 + Double(index) * 0.1) + Double(index))

                    context.opacity = opacity
                    context.fill(
                        Circle().path(in: CGRect(x: position.x - 1.5, y: position.y - 1.5, width: 3, height: 3)),
                        with: .color(.white)
                    )
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ZStack {
        StarFieldBackground(starCount: 80)
        VStack {
            Text("Dreamscape")
                .font(AppFonts.titleLarge)
                .foregroundColor(AppColors.textPrimary)
        }
    }
}
