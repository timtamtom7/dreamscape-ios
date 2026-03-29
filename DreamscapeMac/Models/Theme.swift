import SwiftUI

enum Theme {
    static let cosmicPurple = Color(hex: "6B21A8")
    static let nightBlue = Color(hex: "1E1B4B")
    static let starGold = Color(hex: "F59E0B")
    static let surface = Color(hex: "0F0D1A")
    static let cardBg = Color(hex: "1A1333")
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "A0A0B0")

    // Extended palette
    static let deepVoid = Color(hex: "0A0A14")
    static let nightPurple = Color(hex: "12101F")
    static let nebulaDark = Color(hex: "1A1830")
    static let cosmicSurface = Color(hex: "221E38")
    static let auroraCyan = Color(hex: "5EEAD4")
    static let nebulaPink = Color(hex: "C084FC")
    static let starlight = Color(hex: "F0F0FF")
    static let dimStar = Color(hex: "8B8BA7")
    static let distantStar = Color(hex: "5C5C7A")
    static let dreamGreen = Color(hex: "34D399")
    static let amberGlow = Color(hex: "FBBF24")
    static let meteorRed = Color(hex: "F87171")

    // Gradients
    static let cosmicGradient = LinearGradient(
        colors: [deepVoid, nightPurple, cosmicPurple.opacity(0.3)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardGradient = LinearGradient(
        colors: [cardBg, cosmicSurface.opacity(0.5)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let auroraGradient = LinearGradient(
        colors: [auroraCyan, nebulaPink],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let starGoldGradient = LinearGradient(
        colors: [starGold, amberGlow],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
