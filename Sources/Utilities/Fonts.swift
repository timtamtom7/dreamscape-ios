import SwiftUI

struct AppFonts {
    // iOS HIG minimum font size is 11pt (Caption 2)
    // All font sizes must be >= 11pt per HIG

    static func display(_ size: CGFloat) -> Font {
        .system(size: max(size, 11), weight: .bold, design: .rounded)
    }

    static func heading(_ size: CGFloat) -> Font {
        .system(size: max(size, 11), weight: .semibold, design: .rounded)
    }

    static func body(_ size: CGFloat = 17) -> Font {
        .system(size: max(size, 11), weight: .regular)
    }

    static func mono(_ size: CGFloat = 14) -> Font {
        .system(size: max(size, 11), weight: .regular, design: .monospaced)
    }

    // iOS 26 HIG Typography Scale
    static let titleLarge = Font.system(size: 34, weight: .bold, design: .rounded)       // Large Title 34pt Bold
    static let titleMedium = Font.system(size: 28, weight: .semibold, design: .rounded)    // Title 1 28pt
    static let titleSmall = Font.system(size: 22, weight: .semibold, design: .rounded)    // Title 2 22pt
    static let headline = Font.system(size: 17, weight: .semibold)                          // Headline 17pt Semibold
    static let subheadline = Font.system(size: 15, weight: .medium)                        // Subheadline 15pt
    static let body = Font.system(size: 17, weight: .regular)                               // Body 17pt Regular
    static let callout = Font.system(size: 16, weight: .medium)                             // Callout 16pt
    static let footnote = Font.system(size: 13, weight: .regular)                           // Footnote 13pt
    static let caption = Font.system(size: 12, weight: .regular)                           // Caption 1 12pt
    static let captionBold = Font.system(size: 12, weight: .semibold)                       // Caption Bold 12pt

    // Minimum readable size (11pt - HIG Caption 2)
    static let captionSmall = Font.system(size: 11, weight: .regular)
}
