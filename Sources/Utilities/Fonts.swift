import SwiftUI

struct AppFonts {
    static func display(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func heading(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func body(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular)
    }

    static func mono(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .regular, design: .monospaced)
    }

    static let titleLarge = Font.system(size: 34, weight: .bold, design: .rounded)
    static let titleMedium = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let titleSmall = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 18, weight: .semibold)
    static let subheadline = Font.system(size: 16, weight: .medium)
    static let body = Font.system(size: 16, weight: .regular)
    static let callout = Font.system(size: 14, weight: .medium)
    static let caption = Font.system(size: 12, weight: .regular)
    static let captionBold = Font.system(size: 12, weight: .semibold)
}
