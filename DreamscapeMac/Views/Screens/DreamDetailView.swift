import SwiftUI

struct DreamDetailView: View {
    let dream: Dream
    @Bindable var store: DreamStore
    @Binding var isPresented: Bool

    @State private var isEditing = false
    @State private var editedTitle: String = ""
    @State private var editedNarrative: String = ""
    @State private var editedMood: Dream.Mood = .neutral
    @State private var editedLucidity: Int = 1
    @State private var editedTags: String = ""

    var body: some View {
        ZStack {
            StarFieldView()

            VStack(spacing: 0) {
                headerView

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if isEditing {
                            editingContent
                        } else {
                            displayContent
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            editedTitle = dream.title
            editedNarrative = dream.narrative
            editedMood = dream.mood
            editedLucidity = dream.lucidityLevel
            editedTags = dream.tags.joined(separator: ", ")
        }
    }

    private var headerView: some View {
        HStack {
            Button(action: {
                if isEditing {
                    isEditing = false
                } else {
                    isPresented = false
                }
            }) {
                Image(systemName: isEditing ? "xmark" : "chevron.left")
                    .foregroundColor(Theme.textSecondary)
            }

            Spacer()

            if !isEditing {
                Button(action: { isEditing = true }) {
                    Image(systemName: "pencil")
                        .foregroundColor(Theme.auroraCyan)
                }
            }

            Button(action: deleteDream) {
                Image(systemName: "trash")
                    .foregroundColor(Theme.meteorRed)
            }
        }
        .padding(20)
        .background(Theme.surface)
    }

    private var displayContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title and date
            VStack(alignment: .leading, spacing: 8) {
                Text(dream.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)

                HStack(spacing: 12) {
                    Label(dream.date.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)

                    LucidityBadge(level: dream.lucidityLevel)
                }
            }

            // Mood and tags
            HStack(spacing: 8) {
                MoodTag(mood: dream.mood)

                ForEach(dream.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.cosmicPurple.opacity(0.2))
                        .foregroundColor(Theme.nebulaPink)
                        .cornerRadius(999)
                }
            }

            Divider()
                .background(Theme.distantStar)

            // Narrative
            VStack(alignment: .leading, spacing: 8) {
                Text("Dream Narrative")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)

                Text(dream.narrative)
                    .font(.body)
                    .foregroundColor(Theme.textPrimary)
                    .lineSpacing(4)
            }

            // AI Analysis
            if let summary = dream.summary, !summary.isEmpty {
                DreamAnalysisView(analysis: summary, symbols: dream.detectedSymbols)
            }

            // Detected symbols
            if !dream.detectedSymbols.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Detected Symbols")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)

                    FlowLayout(spacing: 8) {
                        ForEach(dream.detectedSymbols, id: \.self) { symbol in
                            SymbolChipView(name: symbol)
                        }
                    }
                }
            }
        }
    }

    private var editingContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Title")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                TextField("Title", text: $editedTitle)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Theme.cardBg)
                    .cornerRadius(10)
                    .foregroundColor(Theme.textPrimary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Narrative")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                TextEditor(text: $editedNarrative)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(Theme.textPrimary)
                    .frame(minHeight: 150)
                    .padding(8)
                    .background(Theme.cardBg)
                    .cornerRadius(10)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Mood")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Dream.Mood.allCases) { mood in
                            Button(action: { editedMood = mood }) {
                                Text(mood.emoji)
                                    .padding(8)
                                    .background(editedMood == mood ? Theme.cosmicPurple : Theme.cardBg)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Lucidity: \(editedLucidity)/5")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { level in
                        Button(action: { editedLucidity = level }) {
                            Circle()
                                .fill(level <= editedLucidity ? Theme.auroraCyan : Theme.cardBg)
                                .frame(width: 32, height: 32)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Tags")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                TextField("comma, separated, tags", text: $editedTags)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Theme.cardBg)
                    .cornerRadius(10)
                    .foregroundColor(Theme.textPrimary)
            }

            GlowingButton(title: "Save Changes", icon: "checkmark.circle.fill") {
                saveChanges()
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func saveChanges() {
        let tags = editedTags.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        let updatedDream = Dream(
            id: dream.id,
            title: editedTitle,
            narrative: editedNarrative,
            date: dream.date,
            mood: editedMood,
            lucidityLevel: editedLucidity,
            tags: tags,
            summary: dream.summary,
            detectedSymbols: dream.detectedSymbols,
            isAnalyzed: dream.isAnalyzed
        )
        store.updateDream(updatedDream)
        isEditing = false
    }

    private func deleteDream() {
        store.deleteDream(dream)
        isPresented = false
    }
}

struct LucidityBadge: View {
    let level: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
            Text("Lucid \(level)/5")
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Theme.auroraCyan.opacity(0.2))
        .foregroundColor(Theme.auroraCyan)
        .cornerRadius(999)
    }
}

struct SymbolChipView: View {
    let name: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.caption2)
            Text(name.capitalized)
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Theme.starGold.opacity(0.2))
        .foregroundColor(Theme.starGold)
        .cornerRadius(999)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}
