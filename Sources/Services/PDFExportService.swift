import Foundation
import PDFKit
import UIKit

/// R4: PDF Export Service — generates beautiful PDF dream journals
@MainActor
final class PDFExportService {
    static let shared = PDFExportService()

    private init() {}

    // MARK: - Dream Journal PDF

    func generateDreamJournalPDF(dreams: [Dream], title: String = "My Dream Journal") -> Data? {
        let pageWidth: CGFloat = 612  // US Letter
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50

        let pdfMetaData = [
            kCGPDFContextCreator: "Dreamscape",
            kCGPDFContextAuthor: "Dreamscape App",
            kCGPDFContextTitle: title
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            var currentY: CGFloat = 0
            var pageNumber = 0

            func startNewPage(in context: UIGraphicsPDFRendererContext) {
                context.beginPage()
                currentY = margin
                pageNumber += 1

                // Page number
                let pageNumRect = CGRect(x: pageWidth - margin - 50, y: pageHeight - margin + 10, width: 50, height: 20)
                let pageNumAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.gray
                ]
                let pageNumStr = "Page \(pageNumber)"
                pageNumStr.draw(in: pageNumRect, withAttributes: pageNumAttrs)
            }

            // Cover page
            context.beginPage()

            // Background gradient simulation (dark)
            UIColor(red: 0.04, green: 0.04, blue: 0.08, alpha: 1).setFill()
            UIRectFill(CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

            // Decorative circles
            UIColor(red: 0.37, green: 0.92, blue: 0.83, alpha: 0.3).setFill()
            let circle1 = UIBezierPath(ovalIn: CGRect(x: pageWidth - 150, y: -50, width: 200, height: 200))
            circle1.fill()

            UIColor(red: 0.75, green: 0.52, blue: 0.99, alpha: 0.2).setFill()
            let circle2 = UIBezierPath(ovalIn: CGRect(x: -30, y: pageHeight - 200, width: 180, height: 180))
            circle2.fill()

            // Title
            let titleRect = CGRect(x: margin, y: pageHeight / 2 - 80, width: pageWidth - margin * 2, height: 80)
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36, weight: .bold),
                .foregroundColor: UIColor(red: 0.94, green: 0.94, blue: 1, alpha: 1)
            ]
            title.draw(in: titleRect, withAttributes: titleAttrs)

            // Subtitle
            let subtitle = "A Journey Through My Dreams"
            let subtitleRect = CGRect(x: margin, y: pageHeight / 2 - 20, width: pageWidth - margin * 2, height: 30)
            let subtitleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor(red: 0.55, green: 0.55, blue: 0.65, alpha: 1)
            ]
            subtitle.draw(in: subtitleRect, withAttributes: subtitleAttrs)

            // Date range
            let dateRange = formatDateRange(dreams: dreams)
            let dateRect = CGRect(x: margin, y: pageHeight / 2 + 20, width: pageWidth - margin * 2, height: 20)
            let dateAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor(red: 0.37, green: 0.92, blue: 0.83, alpha: 1)
            ]
            dateRange.draw(in: dateRect, withAttributes: dateAttrs)

            // Dream count
            let countStr = "\(dreams.count) Dreams Recorded"
            let countRect = CGRect(x: margin, y: pageHeight / 2 + 50, width: pageWidth - margin * 2, height: 20)
            let countAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor(red: 0.55, green: 0.55, blue: 0.65, alpha: 1)
            ]
            countStr.draw(in: countRect, withAttributes: countAttrs)

            // Footer
            let footerStr = "Created with Dreamscape ✦"
            let footerRect = CGRect(x: margin, y: pageHeight - margin + 20, width: pageWidth - margin * 2, height: 20)
            let footerAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor(red: 0.55, green: 0.55, blue: 0.65, alpha: 1)
            ]
            footerStr.draw(in: footerRect, withAttributes: footerAttrs)

            // Dream pages
            for (index, dream) in dreams.enumerated() {
                startNewPage(in: context)

                // Dream header
                let dreamTitle = "Dream #\(dreams.count - index)"
                let dreamTitleRect = CGRect(x: margin, y: currentY, width: pageWidth - margin * 2, height: 30)
                let dreamTitleAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
                    .foregroundColor: UIColor(red: 0.37, green: 0.92, blue: 0.83, alpha: 1)
                ]
                dreamTitle.draw(in: dreamTitleRect, withAttributes: dreamTitleAttrs)
                currentY += 30

                // Date
                let dateStr = dream.formattedDate
                let dateRect = CGRect(x: margin, y: currentY, width: pageWidth - margin * 2, height: 18)
                let dateAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.monospacedSystemFont(ofSize: 11, weight: .regular),
                    .foregroundColor: UIColor(red: 0.55, green: 0.55, blue: 0.65, alpha: 1)
                ]
                dateStr.draw(in: dateRect, withAttributes: dateAttrs)
                currentY += 25

                // Mood and lucid badge
                var badgesStr = ""
                if let mood = dream.mood {
                    badgesStr += "\(mood.icon) \(mood.displayName)"
                }
                if dream.isLucid {
                    badgesStr += badgesStr.isEmpty ? "✦ Lucid Dream" : "  •  ✦ Lucid Dream"
                }
                if !badgesStr.isEmpty {
                    let badgesRect = CGRect(x: margin, y: currentY, width: pageWidth - margin * 2, height: 20)
                    let badgesAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 12),
                        .foregroundColor: UIColor(red: 0.75, green: 0.52, blue: 0.99, alpha: 1)
                    ]
                    badgesStr.draw(in: badgesRect, withAttributes: badgesAttrs)
                    currentY += 25
                }

                // Summary
                if !dream.summary.isEmpty {
                    let summaryLabel = "Summary"
                    let summaryLabelRect = CGRect(x: margin, y: currentY, width: 100, height: 18)
                    let summaryLabelAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
                        .foregroundColor: UIColor(red: 0.99, green: 0.83, blue: 0.30, alpha: 1)
                    ]
                    summaryLabel.draw(in: summaryLabelRect, withAttributes: summaryLabelAttrs)
                    currentY += 18

                    let summaryRect = CGRect(x: margin, y: currentY, width: pageWidth - margin * 2, height: 60)
                    let summaryAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.italicSystemFont(ofSize: 13),
                        .foregroundColor: UIColor(red: 0.85, green: 0.85, blue: 0.92, alpha: 1)
                    ]
                    dream.summary.draw(in: summaryRect, withAttributes: summaryAttrs)
                    currentY += 65
                }

                // Divider
                UIColor(red: 0.1, green: 0.1, blue: 0.18, alpha: 1).setFill()
                UIRectFill(CGRect(x: margin, y: currentY, width: pageWidth - margin * 2, height: 1))
                currentY += 15

                // Dream content
                let contentLabel = "Dream Entry"
                let contentLabelRect = CGRect(x: margin, y: currentY, width: 100, height: 18)
                let contentLabelAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
                    .foregroundColor: UIColor(red: 0.37, green: 0.92, blue: 0.83, alpha: 1)
                ]
                contentLabel.draw(in: contentLabelRect, withAttributes: contentLabelAttrs)
                currentY += 20

                let contentAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 12),
                    .foregroundColor: UIColor(red: 0.85, green: 0.85, blue: 0.92, alpha: 1)
                ]

                let contentRect = CGRect(x: margin, y: currentY, width: pageWidth - margin * 2, height: pageHeight - currentY - margin - 30)
                dream.content.draw(in: contentRect, withAttributes: contentAttrs)
                currentY += CGFloat(dream.content.count) / 50 * 14 + 30

                // Symbols
                if !dream.symbols.isEmpty {
                    if currentY > pageHeight - 200 {
                        startNewPage(in: context)
                    }

                    let symbolsLabel = "Dream Symbols"
                    let symbolsLabelRect = CGRect(x: margin, y: currentY, width: 150, height: 18)
                    let symbolsLabelAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
                        .foregroundColor: UIColor(red: 0.99, green: 0.83, blue: 0.30, alpha: 1)
                    ]
                    symbolsLabel.draw(in: symbolsLabelRect, withAttributes: symbolsLabelAttrs)
                    currentY += 22

                    let symbolAttrs: [NSAttributedString.Key: Any] = [
                        .font: UIFont.systemFont(ofSize: 11),
                        .foregroundColor: UIColor(red: 0.75, green: 0.52, blue: 0.99, alpha: 1)
                    ]

                    let symbolStr = dream.symbols.map { "\($0.name)" }.joined(separator: "  •  ")
                    let symbolRect = CGRect(x: margin, y: currentY, width: pageWidth - margin * 2, height: pageHeight - currentY - margin)
                    symbolStr.draw(in: symbolRect, withAttributes: symbolAttrs)
                }
            }
        }

        return data
    }

    // MARK: - Annual Yearbook PDF

    func generateYearbookPDF(dreams: [Dream], year: Int) -> Data? {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50

        let yearDreams = dreams.filter { Calendar.current.component(.year, from: $0.createdAt) == year }

        let pdfMetaData = [
            kCGPDFContextCreator: "Dreamscape",
            kCGPDFContextTitle: "Dream Yearbook \(year)"
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            context.beginPage()

            // Dark background
            UIColor(red: 0.04, green: 0.04, blue: 0.08, alpha: 1).setFill()
            UIRectFill(CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

            // Year title
            let yearRect = CGRect(x: margin, y: pageHeight / 2 - 100, width: pageWidth - margin * 2, height: 80)
            let yearAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 56, weight: .bold),
                .foregroundColor: UIColor(red: 0.37, green: 0.92, blue: 0.83, alpha: 1)
            ]
            "\(year)".draw(in: yearRect, withAttributes: yearAttrs)

            let subtitleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18),
                .foregroundColor: UIColor(red: 0.85, green: 0.85, blue: 0.92, alpha: 1)
            ]
            let subtitleRect = CGRect(x: margin, y: pageHeight / 2 - 20, width: pageWidth - margin * 2, height: 30)
            "Dream Yearbook".draw(in: subtitleRect, withAttributes: subtitleAttrs)

            let countStr = "\(yearDreams.count) dreams recorded"
            let countRect = CGRect(x: margin, y: pageHeight / 2 + 20, width: pageWidth - margin * 2, height: 20)
            let countAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor(red: 0.75, green: 0.52, blue: 0.99, alpha: 1)
            ]
            countStr.draw(in: countRect, withAttributes: countAttrs)

            // Stats page
            context.beginPage()
            UIColor(red: 0.04, green: 0.04, blue: 0.08, alpha: 1).setFill()
            UIRectFill(CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

            let statsTitleRect = CGRect(x: margin, y: margin, width: pageWidth - margin * 2, height: 40)
            let statsTitleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .semibold),
                .foregroundColor: UIColor(red: 0.37, green: 0.92, blue: 0.83, alpha: 1)
            ]
            "Your Year in Dreams".draw(in: statsTitleRect, withAttributes: statsTitleAttrs)

            var statsY: CGFloat = margin + 60

            // Total dreams
            let totalDreamStr = "Total Dreams: \(yearDreams.count)"
            let totalAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16),
                .foregroundColor: UIColor(red: 0.85, green: 0.85, blue: 0.92, alpha: 1)
            ]
            totalDreamStr.draw(at: CGPoint(x: margin, y: statsY), withAttributes: totalAttrs)
            statsY += 30

            // Most common mood
            let moodCounts = Dictionary(grouping: yearDreams.compactMap { $0.mood }, by: { $0 })
            if let topMood = moodCounts.max(by: { $0.value.count < $1.value.count }) {
                let moodStr = "Most Common Mood: \(topMood.key.icon) \(topMood.key.displayName)"
                moodStr.draw(at: CGPoint(x: margin, y: statsY), withAttributes: totalAttrs)
                statsY += 30
            }

            // Lucid dream count
            let lucidCount = yearDreams.filter { $0.isLucid }.count
            let lucidStr = "Lucid Dreams: \(lucidCount)"
            lucidStr.draw(at: CGPoint(x: margin, y: statsY), withAttributes: totalAttrs)
            statsY += 30

            // Top symbols
            let allSymbols = yearDreams.flatMap { $0.symbols }
            let symbolCounts = Dictionary(grouping: allSymbols, by: { $0.name }).mapValues { $0.count }
            let topSymbols = symbolCounts.sorted { $0.value > $1.value }.prefix(5)

            statsY += 20
            let topSymbolsTitleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor(red: 0.99, green: 0.83, blue: 0.30, alpha: 1)
            ]
            "Top Dream Symbols:".draw(at: CGPoint(x: margin, y: statsY), withAttributes: topSymbolsTitleAttrs)
            statsY += 25

            let symbolAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 13),
                .foregroundColor: UIColor(red: 0.75, green: 0.52, blue: 0.99, alpha: 1)
            ]
            for (symbol, count) in topSymbols {
                "\(symbol) (\(count))".draw(at: CGPoint(x: margin + 20, y: statsY), withAttributes: symbolAttrs)
                statsY += 22
            }

            // Monthly breakdown
            statsY += 20
            "Monthly Dream Count:".draw(at: CGPoint(x: margin, y: statsY), withAttributes: topSymbolsTitleAttrs)
            statsY += 25

            let monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
            let calendar = Calendar.current
            var monthlyCounts = [Int: Int]()
            for dream in yearDreams {
                let month = calendar.component(.month, from: dream.createdAt)
                monthlyCounts[month, default: 0] += 1
            }

            for (monthNum, name) in monthNames.enumerated() {
                let count = monthlyCounts[monthNum + 1] ?? 0
                let barWidth = CGFloat(count) / max(CGFloat(yearDreams.count), 1) * (pageWidth - margin * 2 - 80)

                let barBgRect = CGRect(x: margin + 50, y: statsY, width: pageWidth - margin * 2 - 80, height: 16)
                UIColor(red: 0.1, green: 0.1, blue: 0.18, alpha: 1).setFill()
                UIRectFill(barBgRect)

                let barRect = CGRect(x: margin + 50, y: statsY, width: barWidth, height: 16)
                UIColor(red: 0.37, green: 0.92, blue: 0.83, alpha: 0.6).setFill()
                UIRectFill(barRect)

                let monthAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 11),
                    .foregroundColor: UIColor(red: 0.85, green: 0.85, blue: 0.92, alpha: 1)
                ]
                "\(name)".draw(at: CGPoint(x: margin, y: statsY), withAttributes: monthAttrs)
                "\(count)".draw(at: CGPoint(x: margin + 50 + barWidth + 5, y: statsY), withAttributes: monthAttrs)

                statsY += 22
            }
        }

        return data
    }

    // MARK: - Timeline PDF

    func generateTimelinePDF(dreams: [Dream]) -> Data? {
        let pageWidth: CGFloat = 792  // Landscape
        let pageHeight: CGFloat = 612
        let margin: CGFloat = 50

        let pdfMetaData = [
            kCGPDFContextCreator: "Dreamscape",
            kCGPDFContextTitle: "Dream Timeline"
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            context.beginPage()

            // Dark background
            UIColor(red: 0.04, green: 0.04, blue: 0.08, alpha: 1).setFill()
            UIRectFill(CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))

            // Title
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                .foregroundColor: UIColor(red: 0.37, green: 0.92, blue: 0.83, alpha: 1)
            ]
            let titleRect = CGRect(x: margin, y: margin, width: pageWidth - margin * 2, height: 40)
            "Your Dream Journey".draw(in: titleRect, withAttributes: titleAttrs)

            // Timeline line
            let lineY = pageHeight / 2
            UIColor(red: 0.1, green: 0.1, blue: 0.18, alpha: 1).setFill()
            UIRectFill(CGRect(x: margin, y: lineY - 1, width: pageWidth - margin * 2, height: 2))

            // Draw dreams along timeline
            let sortedDreams = dreams.sorted { $0.createdAt < $1.createdAt }
            let spacing = (pageWidth - margin * 2) / max(CGFloat(sortedDreams.count + 1), 1)

            for (index, dream) in sortedDreams.enumerated() {
                let x = margin + spacing * CGFloat(index + 1)
                let isTop = index % 2 == 0
                let circleY = lineY - 6

                // Circle marker
                UIColor(red: 0.37, green: 0.92, blue: 0.83, alpha: 1).setFill()
                let circle = UIBezierPath(ovalIn: CGRect(x: x - 6, y: circleY, width: 12, height: 12))
                circle.fill()

                // Dream card
                let cardWidth: CGFloat = 140
                let cardHeight: CGFloat = 100
                let cardX = x - cardWidth / 2
                let cardY = isTop ? lineY - cardHeight - 30 : lineY + 30

                UIColor(red: 0.1, green: 0.09, blue: 0.19, alpha: 0.95).setFill()
                let cardRect = UIBezierPath(roundedRect: CGRect(x: cardX, y: cardY, width: cardWidth, height: cardHeight), cornerRadius: 8)
                cardRect.fill()

                // Date
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d"
                let dateStr = dateFormatter.string(from: dream.createdAt)
                let dateAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.monospacedSystemFont(ofSize: 9, weight: .regular),
                    .foregroundColor: UIColor(red: 0.37, green: 0.92, blue: 0.83, alpha: 1)
                ]
                dateStr.draw(at: CGPoint(x: cardX + 8, y: cardY + 8), withAttributes: dateAttrs)

                // Summary snippet
                let snippetAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 9),
                    .foregroundColor: UIColor(red: 0.85, green: 0.85, blue: 0.92, alpha: 1)
                ]
                let snippet = dream.summary.isEmpty ? dream.content.prefix(60) + "..." : dream.summary.prefix(60) + "..."
                let snippetRect = CGRect(x: cardX + 8, y: cardY + 25, width: cardWidth - 16, height: 60)
                String(snippet).draw(in: snippetRect, withAttributes: snippetAttrs)

                // Connecting line
                UIColor(red: 0.37, green: 0.92, blue: 0.83, alpha: 0.3).setFill()
                let connectorStartY = isTop ? cardY + cardHeight : cardY
                let connectorEndY = lineY
                UIRectFill(CGRect(x: x - 0.5, y: min(connectorStartY, connectorEndY), width: 1, height: abs(connectorEndY - connectorStartY)))
            }
        }

        return data
    }

    // MARK: - Helpers

    private func formatDateRange(dreams: [Dream]) -> String {
        let sorted = dreams.sorted { $0.createdAt < $1.createdAt }
        guard let first = sorted.first, let last = sorted.last else {
            return "No dreams recorded"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"

        return "\(formatter.string(from: first.createdAt)) — \(formatter.string(from: last.createdAt))"
    }
}
