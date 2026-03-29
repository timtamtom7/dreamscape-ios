import SwiftUI

struct DreamJournalView: View {
    @Bindable var store: DreamStore
    @State private var searchText = ""
    @State private var selectedMood: Dream.Mood?
    @State private var selectedDream: Dream?
    @State private var showingNewDream = false
    @State private var showingDetail = false

    var filteredDreams: [Dream] {
        var result = store.dreams

        if !searchText.isEmpty {
            result = store.searchDreams(searchText)
        }

        if let mood = selectedMood {
            result = result.filter { $0.mood == mood }
        }

        return result
    }

    var body: some View {
        ZStack {
            StarFieldView()

            VStack(spacing: 0) {
                headerView
                searchAndFilterView
                dreamListView
            }
        }
        .sheet(isPresented: $showingNewDream) {
            NewDreamView(store: store, isPresented: $showingNewDream)
        }
        .sheet(isPresented: $showingDetail) {
            if let dream = selectedDream {
                DreamDetailView(dream: dream, store: store, isPresented: $showingDetail)
            }
        }
    }

    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "moon.stars.fill")
                    .font(.title2)
                    .foregroundColor(Theme.starGold)
                Text("Dream Journal")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                StreakBadge(count: store.streak)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            HStack {
                Text("\(store.dreams.count) dreams recorded")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }

    private var searchAndFilterView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Theme.textSecondary)
                TextField("Search dreams...", text: $searchText)
                    .textFieldStyle(.plain)
                    .foregroundColor(Theme.textPrimary)
            }
            .padding(10)
            .background(Theme.cardBg)
            .cornerRadius(10)
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(title: "All", isSelected: selectedMood == nil) {
                        selectedMood = nil
                    }
                    ForEach(Dream.Mood.allCases) { mood in
                        FilterChip(
                            title: "\(mood.emoji) \(mood.rawValue)",
                            isSelected: selectedMood == mood
                        ) {
                            selectedMood = mood
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 12)
    }

    private var dreamListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if filteredDreams.isEmpty {
                    emptyStateView
                } else {
                    ForEach(filteredDreams) { dream in
                        DreamCard(dream: dream) {
                            selectedDream = dream
                            showingDetail = true
                        }
                        .contextMenu {
                            Button("Edit") {
                                selectedDream = dream
                                showingDetail = true
                            }
                            Button("Delete", role: .destructive) {
                                store.deleteDream(dream)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 48))
                .foregroundColor(Theme.cosmicPurple)
            Text("Your dreams await...")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
            Text("Record your first dream to begin your journey")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Theme.cosmicPurple : Theme.cardBg)
                .foregroundColor(isSelected ? .white : Theme.textSecondary)
                .cornerRadius(999)
        }
        .buttonStyle(.plain)
    }
}

struct StreakBadge: View {
    let count: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundColor(Theme.amberGlow)
            Text("\(count)")
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Theme.cardBg)
        .cornerRadius(8)
    }
}

struct NewDreamView: View {
    @Bindable var store: DreamStore
    @Binding var isPresented: Bool

    @State private var title = ""
    @State private var narrative = ""
    @State private var selectedMood: Dream.Mood = .neutral
    @State private var lucidityLevel = 1
    @State private var tagsText = ""

    var body: some View {
        ZStack {
            StarFieldView()

            VStack(spacing: 0) {
                headerView
                ScrollView {
                    VStack(spacing: 20) {
                        titleField
                        narrativeField
                        moodSelector
                        luciditySelector
                        tagsField
                    }
                    .padding(20)
                }
                saveButton
            }
        }
    }

    private var headerView: some View {
        HStack {
            Button("Cancel") {
                isPresented = false
            }
            .foregroundColor(Theme.textSecondary)

            Spacer()

            Text("New Dream")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)

            Spacer()

            Button("Save") {
                saveDream()
            }
            .foregroundColor(Theme.auroraCyan)
            .disabled(title.isEmpty || narrative.isEmpty)
        }
        .padding(20)
        .background(Theme.surface)
    }

    private var titleField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
            TextField("Dream title...", text: $title)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Theme.cardBg)
                .cornerRadius(10)
                .foregroundColor(Theme.textPrimary)
        }
    }

    private var narrativeField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dream Narrative")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
            TextEditor(text: $narrative)
                .scrollContentBackground(.hidden)
                .foregroundColor(Theme.textPrimary)
                .frame(minHeight: 120)
                .padding(8)
                .background(Theme.cardBg)
                .cornerRadius(10)
        }
    }

    private var moodSelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mood")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Dream.Mood.allCases) { mood in
                        Button(action: { selectedMood = mood }) {
                            VStack(spacing: 4) {
                                Text(mood.emoji)
                                    .font(.title2)
                                Text(mood.rawValue)
                                    .font(.caption2)
                            }
                            .padding(8)
                            .background(selectedMood == mood ? Theme.cosmicPurple : Theme.cardBg)
                            .cornerRadius(10)
                            .foregroundColor(selectedMood == mood ? .white : Theme.textSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var luciditySelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Lucidity Level")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                Spacer()
                Text("\(lucidityLevel)/5")
                    .font(.caption)
                    .foregroundColor(Theme.auroraCyan)
            }
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { level in
                    Button(action: { lucidityLevel = level }) {
                        Circle()
                            .fill(level <= lucidityLevel ? Theme.auroraCyan : Theme.cardBg)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("\(level)")
                                    .font(.caption)
                                    .foregroundColor(level <= lucidityLevel ? .black : Theme.textSecondary)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var tagsField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags (comma separated)")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
            TextField("flying, ocean, stars...", text: $tagsText)
                .textFieldStyle(.plain)
                .padding(12)
                .background(Theme.cardBg)
                .cornerRadius(10)
                .foregroundColor(Theme.textPrimary)
        }
    }

    private var saveButton: some View {
        GlowingButton(title: "Record Dream", icon: "plus.circle.fill") {
            saveDream()
        }
        .padding(20)
    }

    private func saveDream() {
        let tags = tagsText.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        let dream = Dream(
            title: title,
            narrative: narrative,
            mood: selectedMood,
            lucidityLevel: lucidityLevel,
            tags: tags
        )
        let analyzedDream = store.analyzeDream(dream)
        store.addDream(analyzedDream)
        isPresented = false
    }
}
