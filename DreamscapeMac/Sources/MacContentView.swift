import SwiftUI

struct MacContentView: View {
    @State private var selectedDream: Dream?
    @State private var showingEntry = false
    @State private var dreams: [Dream] = []

    var body: some View {
        NavigationSplitView {
            // Sidebar
            VStack(spacing: 0) {
                // Add button
                Button {
                    showingEntry = true
                } label: {
                    Label("New Dream", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .background(Color(nsColor: NSColor.controlAccentColor).opacity(0.15))
                .cornerRadius(8)
                .padding(12)

                Divider()

                // Dream list
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(sortedDreams) { dream in
                            MacDreamRow(dream: dream, isSelected: selectedDream?.id == dream.id)
                                .onTapGesture {
                                    selectedDream = dream
                                }
                        }
                    }
                    .padding(12)
                }
            }
            .frame(minWidth: 260, idealWidth: 300)
            .background(Color(nsColor: NSColor.windowBackgroundColor))
            .navigationTitle("Dreamscape")
        } detail: {
            // Detail view
            if let dream = selectedDream {
                MacDreamDetailView(dream: dream)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "moon.stars")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary.opacity(0.3))
                    Text("Select a dream to view")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: NSColor.textBackgroundColor))
            }
        }
        .tint(Color(nsColor: NSColor.controlAccentColor))
        .sheet(isPresented: $showingEntry) {
            MacDreamEntryView { dream in
                dreams.insert(dream, at: 0)
            }
        }
        .onAppear {
            loadDreams()
        }
    }

    private var sortedDreams: [Dream] {
        dreams.sorted { $0.createdAt > $1.createdAt }
    }

    private func loadDreams() {
        // Load dreams from UserDefaults
        if let data = UserDefaults.standard.data(forKey: "mac_dreams"),
           let decoded = try? JSONDecoder().decode([Dream].self, from: data) {
            dreams = decoded
        }
    }

    private func saveDreams() {
        if let encoded = try? JSONEncoder().encode(dreams) {
            UserDefaults.standard.set(encoded, forKey: "mac_dreams")
        }
    }
}

struct MacDreamRow: View {
    let dream: Dream
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(dream.shortFormattedDate)
                .font(.caption2)
                .foregroundColor(.secondary)

            Text(dream.summary.isEmpty ? "Dream" : dream.summary)
                .font(.subheadline)
                .foregroundColor(.primary)
                .lineLimit(2)

            HStack(spacing: 4) {
                if dream.isLucid {
                    Text("Lucid")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.purple)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.purple.opacity(0.15))
                        .cornerRadius(3)
                }

                Text("\(dream.symbols.count) symbols")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? Color(nsColor: NSColor.selectedContentBackgroundColor).opacity(0.3) : Color(nsColor: NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1)
        )
    }
}

struct MacDreamDetailView: View {
    let dream: Dream

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(dream.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if !dream.summary.isEmpty {
                        Text(dream.summary)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }

                // Tags
                HStack(spacing: 8) {
                    if let mood = dream.mood {
                        HStack(spacing: 4) {
                            Image(systemName: mood.icon)
                            Text(mood.displayName)
                        }
                        .font(.caption)
                        .foregroundColor(mood.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(mood.color.opacity(0.15))
                        .cornerRadius(8)
                    }

                    if dream.isLucid {
                        HStack(spacing: 4) {
                            Image(systemName: "eye.fill")
                            Text("Lucid")
                        }
                        .font(.caption)
                        .foregroundColor(.purple)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.15))
                        .cornerRadius(8)
                    }
                }

                // Dream content
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dream")
                        .font(.headline)

                    Text(dream.content)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                }

                // Symbols
                if !dream.symbols.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Symbols")
                            .font(.headline)

                        FlowLayoutMac(spacing: 6) {
                            ForEach(dream.symbols) { symbol in
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(symbolColor(symbol.category))
                                        .frame(width: 6, height: 6)
                                    Text(symbol.name)
                                }
                                .font(.caption)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(nsColor: NSColor.controlBackgroundColor))
                                .cornerRadius(12)
                            }
                        }
                    }
                }

                // Emotional tags
                if !dream.emotionalTags.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Emotions")
                            .font(.headline)

                        FlowLayoutMac(spacing: 6) {
                            ForEach(dream.emotionalTags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .foregroundColor(.pink)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.pink.opacity(0.15))
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: NSColor.textBackgroundColor))
        .navigationTitle("Dream")
    }

    private func symbolColor(_ category: SymbolCategory) -> Color {
        switch category {
        case .person: return .purple
        case .place: return .blue
        case .object: return .orange
        case .emotion: return .cyan
        }
    }
}

struct MacDreamEntryView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Dream) -> Void

    @State private var content = ""
    @State private var mood: MoodTag?
    @State private var isLucid = false
    @State private var isAnalyzing = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                TextEditor(text: $content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .scrollContentBackground(.hidden)
                    .background(Color(nsColor: NSColor.controlBackgroundColor))
                    .cornerRadius(12)

                HStack(spacing: 16) {
                    Toggle("Lucid Dream", isOn: $isLucid)

                    if !dreamsMoods.isEmpty {
                        Picker("Mood", selection: $mood) {
                            Text("None").tag(nil as MoodTag?)
                            ForEach(dreamsMoods, id: \.self) { tag in
                                Text(tag.displayName).tag(tag as MoodTag?)
                            }
                        }
                    }
                }
                .font(.subheadline)

                Spacer()
            }
            .padding(24)
            .background(Color(nsColor: NSColor.textBackgroundColor))
            .navigationTitle("New Dream")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).count < 10)
                }
            }
        }
    }

    private var dreamsMoods: [MoodTag] {
        MoodTag.allCases
    }

    private func save() {
        let dream = Dream(
            content: content,
            mood: mood,
            isLucid: isLucid
        )
        onSave(dream)
        dismiss()
    }
}

// Simple flow layout for macOS
struct FlowLayoutMac: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResultMac(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResultMac(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResultMac {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + rowHeight)
        }
    }
}
