import SwiftUI

struct IdentifiableString: Identifiable {
    let id = UUID()
    let value: String
}

struct DreamDictionaryView: View {
    @StateObject private var dictionaryStore = DreamDictionaryStore.shared
    @State private var searchText = ""
    @State private var selectedSymbol: IdentifiableString?
    @State private var showingAddSymbol = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Search
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppColors.textSecondary)
                        TextField("Search your dream dictionary...", text: $searchText)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding()
                    .background(AppColors.surface)
                    .cornerRadius(12)
                    .padding()

                    if filteredSymbols.isEmpty {
                        emptyState
                    } else {
                        symbolsList
                    }
                }
            }
            .navigationTitle("Dream Dictionary")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSymbol = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppColors.auroraCyan)
                    }
                }
            }
            .sheet(isPresented: $showingAddSymbol) {
                AddSymbolMeaningSheet()
            }
            .sheet(item: $selectedSymbol) { item in
                SymbolMeaningDetailView(symbolName: item.value)
            }
        }
    }

    private var filteredSymbols: [PersonalSymbolMeaning] {
        if searchText.isEmpty {
            return dictionaryStore.allSymbols
        }
        return dictionaryStore.allSymbols.filter {
            $0.symbolName.localizedCaseInsensitiveContains(searchText) ||
            $0.meaning.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "book.closed.fill")
                .font(.system(size: 64))
                .foregroundColor(AppColors.textMuted)

            Text("Your Personal Dictionary")
                .font(AppFonts.titleSmall)
                .foregroundColor(AppColors.textPrimary)

            Text("As you record more dreams, your personal symbol meanings will build here — unique to YOUR subconscious.")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                showingAddSymbol = true
            } label: {
                Label("Add First Symbol", systemImage: "plus.circle.fill")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.backgroundPrimary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppColors.auroraCyan)
                    .cornerRadius(25)
            }

            Spacer()
        }
    }

    private var symbolsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredSymbols) { symbol in
                    DictionarySymbolRow(symbol: symbol)
                        .onTapGesture {
                            selectedSymbol = IdentifiableString(value: symbol.symbolName)
                        }
                }
            }
            .padding()
        }
    }
}

struct DictionarySymbolRow: View {
    let symbol: PersonalSymbolMeaning

    var body: some View {
        HStack(spacing: 16) {
            // Frequency badge
            ZStack {
                Circle()
                    .fill(AppColors.nebulaPink.opacity(0.2))
                    .frame(width: 44, height: 44)

                Text("\(symbol.frequency)")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.nebulaPink)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(symbol.symbolName)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)

                Text(symbol.meaning.isEmpty ? "No meaning recorded" : symbol.meaning)
                    .font(AppFonts.callout)
                    .foregroundColor(symbol.meaning.isEmpty ? AppColors.textMuted : AppColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppColors.textMuted)
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(12)
    }
}

struct SymbolMeaningDetailView: View {
    let symbolName: String
    @StateObject private var dictionaryStore = DreamDictionaryStore.shared
    @State private var showingEdit = false

    private var symbol: PersonalSymbolMeaning? {
        dictionaryStore.meaning(for: symbolName)
    }

    private var evolutionHistory: [SymbolEvolutionEvent] {
        dictionaryStore.evolutionHistory(for: symbolName)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(symbolName)
                                    .font(AppFonts.titleMedium)
                                    .foregroundColor(AppColors.textPrimary)

                                Spacer()

                                if let s = symbol {
                                    Text("\(s.frequency) dream\(s.frequency == 1 ? "" : "s")")
                                        .font(AppFonts.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(AppColors.nebulaPink.opacity(0.15))
                                        .cornerRadius(999)
                                }
                            }

                            if let meaning = symbol?.meaning, !meaning.isEmpty {
                                Text(meaning)
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textSecondary)
                            } else {
                                Text("Tap edit to record what this symbol means to you personally.")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textMuted)
                                    .italic()
                            }
                        }
                        .padding()
                        .background(AppColors.surface)
                        .cornerRadius(16)

                        // Personal meaning
                        Button {
                            showingEdit = true
                        } label: {
                            Label(symbol?.meaning.isEmpty == true ? "Add Your Meaning" : "Edit Meaning", systemImage: "pencil")
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.auroraCyan)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.auroraCyan.opacity(0.1))
                                .cornerRadius(12)
                        }

                        // Evolution history
                        if !evolutionHistory.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Meaning Evolution")
                                    .font(AppFonts.headline)
                                    .foregroundColor(AppColors.textPrimary)

                                Text("How your understanding of '\(symbolName)' has changed over time")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textSecondary)

                                ForEach(evolutionHistory) { event in
                                    evolutionEventRow(event)
                                }
                            }
                        }

                        // Examples
                        if let examples = symbol?.examples, !examples.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Your Examples")
                                    .font(AppFonts.headline)
                                    .foregroundColor(AppColors.textPrimary)

                                ForEach(examples, id: \.self) { example in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "quote.opening")
                                            .font(.caption)
                                            .foregroundColor(AppColors.nebulaPink)
                                        Text(example)
                                            .font(AppFonts.callout)
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    .padding()
                                    .background(AppColors.surface)
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(symbolName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        // Dismiss handled by sheet
                    }
                }
            }
            .sheet(isPresented: $showingEdit) {
                if let s = symbol {
                    EditSymbolMeaningSheet(symbol: s)
                }
            }
        }
    }

    private func evolutionEventRow(_ event: SymbolEvolutionEvent) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(event.eventDate.formatted(date: .abbreviated, time: .omitted))
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
                Spacer()
            }

            if let previous = event.previousMeaning {
                Text("Changed from: \"\(previous)\"")
                    .font(AppFonts.callout)
                    .foregroundColor(AppColors.textMuted)
                    .strikethrough()
            }

            Text("To: \"\(event.newMeaning)\"")
                .font(AppFonts.callout)
                .foregroundColor(AppColors.auroraCyan)
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(8)
    }
}

struct AddSymbolMeaningSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dictionaryStore = DreamDictionaryStore.shared
    @State private var symbolName = ""
    @State private var meaning = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 24) {
                    Text("Symbol Name")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)

                    TextField("e.g. Water, Flying, House", text: $symbolName)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                        .padding()
                        .background(AppColors.surface)
                        .cornerRadius(12)

                    Text("What does this symbol mean to YOU?")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)

                    TextEditor(text: $meaning)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 120)
                        .padding()
                        .background(AppColors.surface)
                        .cornerRadius(12)

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Add Symbol")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(symbolName.trimmingCharacters(in: .whitespacesAndNewlines).count < 2)
                }
            }
        }
    }

    private func save() {
        let symbol = PersonalSymbolMeaning(
            symbolName: symbolName.trimmingCharacters(in: .whitespacesAndNewlines),
            meaning: meaning.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        dictionaryStore.setMeaning(symbol)
        dismiss()
    }
}

struct EditSymbolMeaningSheet: View {
    let symbol: PersonalSymbolMeaning
    @Environment(\.dismiss) private var dismiss
    @StateObject private var dictionaryStore = DreamDictionaryStore.shared
    @State private var meaning: String
    @State private var newExample = ""

    init(symbol: PersonalSymbolMeaning) {
        self.symbol = symbol
        _meaning = State(initialValue: symbol.meaning)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Your Meaning")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)

                        TextEditor(text: $meaning)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 120)
                            .padding()
                            .background(AppColors.surface)
                            .cornerRadius(12)

                        Text("Add an Example")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)

                        HStack {
                            TextField("e.g. 'I was swimming in dark water'", text: $newExample)
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)

                            if !newExample.isEmpty {
                                Button {
                                    addExample()
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(AppColors.auroraCyan)
                                }
                            }
                        }
                        .padding()
                        .background(AppColors.surface)
                        .cornerRadius(12)

                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit: \(symbol.symbolName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                }
            }
        }
    }

    private func addExample() {
        guard !newExample.isEmpty else { return }
        dictionaryStore.addExample(newExample, to: symbol.symbolName)
        newExample = ""
    }

    private func save() {
        var updated = symbol
        updated.meaning = meaning
        updated.updatedAt = Date()
        dictionaryStore.setMeaning(updated)
        dismiss()
    }
}
