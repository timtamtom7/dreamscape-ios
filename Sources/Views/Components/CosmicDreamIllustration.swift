import SwiftUI

/// A stylized cosmic dream illustration for empty states.
struct CosmicDreamIllustration: View {
    let size: CGFloat

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let scale = size / 300

            // Stars — scattered small circles
            let starPositions: [(CGPoint, CGFloat, Color)] = [
                (CGPoint(x: 40 * scale, y: 30 * scale), 2 * scale, Color.white.opacity(0.4)),
                (CGPoint(x: 120 * scale, y: 15 * scale), 1.5 * scale, Color.white.opacity(0.3)),
                (CGPoint(x: 200 * scale, y: 25 * scale), 2.5 * scale, Color.white.opacity(0.5)),
                (CGPoint(x: 260 * scale, y: 10 * scale), 1 * scale, Color.white.opacity(0.2)),
                (CGPoint(x: 20 * scale, y: 80 * scale), 1 * scale, Color.white.opacity(0.3)),
                (CGPoint(x: 280 * scale, y: 70 * scale), 2 * scale, Color.white.opacity(0.4)),
                (CGPoint(x: 15 * scale, y: 150 * scale), 1.5 * scale, Color.white.opacity(0.3)),
                (CGPoint(x: 285 * scale, y: 140 * scale), 1 * scale, Color.white.opacity(0.2)),
                (CGPoint(x: 30 * scale, y: 220 * scale), 2 * scale, Color.white.opacity(0.4)),
                (CGPoint(x: 100 * scale, y: 250 * scale), 1 * scale, Color.white.opacity(0.3)),
                (CGPoint(x: 200 * scale, y: 270 * scale), 1.5 * scale, Color.white.opacity(0.3)),
                (CGPoint(x: 270 * scale, y: 230 * scale), 2 * scale, Color.white.opacity(0.4)),
            ]

            for (pos, radius, color) in starPositions {
                var path = Path()
                path.addEllipse(in: CGRect(
                    x: pos.x - radius,
                    y: pos.y - radius,
                    width: radius * 2,
                    height: radius * 2
                ))
                context.fill(path, with: .color(color))
            }

            // Moon
            let moonCenter = CGPoint(x: center.x + 40 * scale, y: center.y - 30 * scale)
            let moonRadius = 45 * scale
            var moonPath = Path()
            moonPath.addEllipse(in: CGRect(
                x: moonCenter.x - moonRadius,
                y: moonCenter.y - moonRadius,
                width: moonRadius * 2,
                height: moonRadius * 2
            ))
            // Moon glow
            context.fill(Path { p in
                p.addEllipse(in: CGRect(
                    x: moonCenter.x - moonRadius * 1.5,
                    y: moonCenter.y - moonRadius * 1.5,
                    width: moonRadius * 3,
                    height: moonRadius * 3
                ))
            }, with: .radialGradient(
                Gradient(colors: [AppColors.starGold.opacity(0.15), .clear]),
                center: moonCenter,
                startRadius: moonRadius * 0.5,
                endRadius: moonRadius * 2.5
            ))
            context.fill(moonPath, with: .color(AppColors.starGold.opacity(0.9)))
            // Moon craters (subtle)
            var crater1 = Path()
            crater1.addEllipse(in: CGRect(
                x: moonCenter.x - 15 * scale,
                y: moonCenter.y - 10 * scale,
                width: 12 * scale,
                height: 12 * scale
            ))
            context.fill(crater1, with: .color(AppColors.starGold.opacity(0.6)))
            var crater2 = Path()
            crater2.addEllipse(in: CGRect(
                x: moonCenter.x + 8 * scale,
                y: moonCenter.y + 5 * scale,
                width: 8 * scale,
                height: 8 * scale
            ))
            context.fill(crater2, with: .color(AppColors.starGold.opacity(0.5)))

            // Dream cloud
            let cloudCenter = CGPoint(x: center.x - 30 * scale, y: center.y + 20 * scale)
            let cloudColor = AppColors.nebulaPink.opacity(0.25)
            let cloudParts: [(CGPoint, CGFloat)] = [
                (CGPoint(x: cloudCenter.x - 30 * scale, y: cloudCenter.y), 30 * scale),
                (CGPoint(x: cloudCenter.x + 10 * scale, y: cloudCenter.y - 10 * scale), 35 * scale),
                (CGPoint(x: cloudCenter.x + 40 * scale, y: cloudCenter.y + 5 * scale), 28 * scale),
                (CGPoint(x: cloudCenter.x + 5 * scale, y: cloudCenter.y + 15 * scale), 25 * scale),
            ]
            for (pc, rc) in cloudParts {
                var cloudPath = Path()
                cloudPath.addEllipse(in: CGRect(
                    x: pc.x - rc,
                    y: pc.y - rc,
                    width: rc * 2,
                    height: rc * 2
                ))
                context.fill(cloudPath, with: .color(cloudColor))
            }

            // Aurora swirl
            var auroraPath = Path()
            auroraPath.move(to: CGPoint(x: center.x - 80 * scale, y: center.y + 60 * scale))
            auroraPath.addQuadCurve(
                to: CGPoint(x: center.x + 80 * scale, y: center.y + 40 * scale),
                control: CGPoint(x: center.x, y: center.y + 10 * scale)
            )
            context.stroke(auroraPath, with: .color(AppColors.auroraCyan.opacity(0.4)), lineWidth: 3 * scale)

            var auroraPath2 = Path()
            auroraPath2.move(to: CGPoint(x: center.x - 70 * scale, y: center.y + 75 * scale))
            auroraPath2.addQuadCurve(
                to: CGPoint(x: center.x + 70 * scale, y: center.y + 55 * scale),
                control: CGPoint(x: center.x + 10 * scale, y: center.y + 30 * scale)
            )
            context.stroke(auroraPath2, with: .color(AppColors.nebulaPink.opacity(0.3)), lineWidth: 2 * scale)

            // Shooting star trail
            var trailPath = Path()
            trailPath.move(to: CGPoint(x: 80 * scale, y: 60 * scale))
            trailPath.addLine(to: CGPoint(x: 140 * scale, y: 95 * scale))
            context.stroke(trailPath, with: .linearGradient(
                Gradient(colors: [Color.white.opacity(0), Color.white.opacity(0.6)]),
                startPoint: CGPoint(x: 80 * scale, y: 60 * scale),
                endPoint: CGPoint(x: 140 * scale, y: 95 * scale)
            ), lineWidth: 2 * scale)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ZStack {
        AppColors.backgroundPrimary.ignoresSafeArea()
        CosmicDreamIllustration(size: 280)
    }
    .preferredColorScheme(.dark)
}
