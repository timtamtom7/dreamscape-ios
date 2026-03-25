import SwiftUI

struct FamilyDreamShareView: View {
    @StateObject private var familyStore = FamilyShareStore.shared
    @EnvironmentObject var journalViewModel: JournalViewModel
    @State private var showingAddFamily = false
    @State private var showingShareDream = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        headerSection

                        // Family profiles
                        if familyStore.familyProfiles.isEmpty {
                            emptyState
                        } else {
                            familyProfilesSection
                        }

                        // Shared dreams comparison
                        if !familyStore.familyProfiles.isEmpty {
                            sharedDreamsSection
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Family Dreams")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddFamily = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .foregroundColor(AppColors.auroraCyan)
                    }
                }
            }
            .sheet(isPresented: $showingAddFamily) {
                AddFamilyMemberSheet()
            }
            .sheet(isPresented: $showingShareDream) {
                ShareDreamSheet()
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dream Connections")
                .font(AppFonts.titleSmall)
                .foregroundColor(AppColors.textPrimary)

            Text("Share dreams with your partner or family to discover shared symbols and recurring patterns you both experience.")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 64))
                .foregroundColor(AppColors.textMuted)

            Text("Connect Through Dreams")
                .font(AppFonts.titleSmall)
                .foregroundColor(AppColors.textPrimary)

            Text("Add family members or partners to start sharing dream symbols and discovering patterns you share.")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                showingAddFamily = true
            } label: {
                Label("Add First Connection", systemImage: "person.badge.plus")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.backgroundPrimary)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppColors.auroraCyan)
                    .cornerRadius(25)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var familyProfilesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dream Partners")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)

            ForEach(familyStore.familyProfiles) { profile in
                FamilyProfileCard(profile: profile)
            }
        }
    }

    private var sharedDreamsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Shared Symbols")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Button {
                    showingShareDream = true
                } label: {
                    Label("Share Dream", systemImage: "plus.circle.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.auroraCyan)
                }
            }

            Text("Symbols you both dream about frequently")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)

            sharedSymbolsGrid
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    @ViewBuilder
    private var sharedSymbolsGrid: some View {
        let sharedSymbols = getSharedSymbols()

        if sharedSymbols.isEmpty {
            Text("Share dreams to discover shared symbols")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textMuted)
                .italic()
        } else {
            FlowLayout(spacing: 8) {
                ForEach(Array(sharedSymbols.prefix(10)), id: \.self) { symbol in
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                        Text(symbol)
                    }
                    .font(.caption)
                    .foregroundColor(AppColors.starGold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.starGold.opacity(0.15))
                    .cornerRadius(12)
                }
            }
        }
    }

    private func getSharedSymbols() -> [String] {
        var allSymbols: [String: Set<UUID>] = [:]

        for profile in familyStore.familyProfiles {
            for dreamId in profile.sharedDreamIds {
                if let dream = journalViewModel.dreams.first(where: { $0.id == dreamId }) {
                    for symbol in dream.symbols {
                        allSymbols[symbol.name, default: Set()].insert(profile.id)
                    }
                }
            }
        }

        return allSymbols.filter { $0.value.count > 1 }.map { $0.key }
    }
}

struct FamilyProfileCard: View {
    let profile: FamilyDreamProfile
    @StateObject private var familyStore = FamilyShareStore.shared
    @State private var showingDelete = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(profile.avatarEmoji)
                    .font(.title)

                VStack(alignment: .leading, spacing: 2) {
                    Text(profile.name)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Text("\(profile.sharedDreamIds.count) shared dreams")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Button {
                    showingDelete = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.error.opacity(0.5))
                }
            }
        }
        .padding()
        .background(AppColors.surface)
        .cornerRadius(16)
        .alert("Remove \(profile.name)?", isPresented: $showingDelete) {
            Button("Remove", role: .destructive) {
                familyStore.removeProfile(id: profile.id)
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

struct AddFamilyMemberSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var familyStore = FamilyShareStore.shared
    @State private var name = ""
    @State private var selectedEmoji = "👤"

    private let emojiOptions = ["👤", "👩", "👨", "👦", "👧", "👴", "👵", "🧑", "🧒", "🐶", "🐱"]

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 24) {
                    Text("Who do you share dreams with?")
                        .font(AppFonts.titleSmall)
                        .foregroundColor(AppColors.textPrimary)

                    // Emoji picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Avatar")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                            ForEach(emojiOptions, id: \.self) { emoji in
                                Button {
                                    selectedEmoji = emoji
                                } label: {
                                    Text(emoji)
                                        .font(.title2)
                                        .padding(8)
                                        .background(selectedEmoji == emoji ? AppColors.auroraCyan.opacity(0.2) : Color.clear)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedEmoji == emoji ? AppColors.auroraCyan : Color.clear, lineWidth: 2)
                                        )
                                }
                            }
                        }
                    }

                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)

                        TextField("Partner, family member...", text: $name)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                            .padding()
                            .background(AppColors.surface)
                            .cornerRadius(12)
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Add Dream Partner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let profile = FamilyDreamProfile(name: name, avatarEmoji: selectedEmoji)
                        familyStore.addProfile(profile)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).count < 2)
                }
            }
        }
    }
}

struct ShareDreamSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var journalViewModel: JournalViewModel
    @StateObject private var familyStore = FamilyShareStore.shared
    @State private var selectedDreamId: UUID?
    @State private var selectedPartnerId: UUID?

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 24) {
                    Text("Share a Dream")
                        .font(AppFonts.titleSmall)
                        .foregroundColor(AppColors.textPrimary)

                    // Select dream
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select Dream")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(journalViewModel.dreams.prefix(10)) { dream in
                                    Button {
                                        selectedDreamId = dream.id
                                    } label: {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(dream.shortFormattedDate)
                                                .font(.caption2)
                                                .foregroundColor(AppColors.auroraCyan)

                                            Text(dream.summary.isEmpty ? dream.content.prefix(30) + "..." : dream.summary.prefix(30) + "...")
                                                .font(.caption)
                                                .foregroundColor(AppColors.textPrimary)
                                                .lineLimit(2)
                                        }
                                        .padding()
                                        .frame(width: 140)
                                        .background(selectedDreamId == dream.id ? AppColors.auroraCyan.opacity(0.2) : AppColors.surface)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedDreamId == dream.id ? AppColors.auroraCyan : Color.clear, lineWidth: 2)
                                        )
                                    }
                                }
                            }
                        }
                    }

                    // Select partner
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Share With")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)

                        ForEach(familyStore.familyProfiles) { profile in
                            Button {
                                selectedPartnerId = profile.id
                            } label: {
                                HStack {
                                    Text(profile.avatarEmoji)
                                    Text(profile.name)
                                        .font(AppFonts.body)
                                        .foregroundColor(AppColors.textPrimary)
                                    Spacer()
                                    if selectedPartnerId == profile.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(AppColors.auroraCyan)
                                    }
                                }
                                .padding()
                                .background(AppColors.surface)
                                .cornerRadius(12)
                            }
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Share Dream")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Share") {
                        if let dreamId = selectedDreamId, let partnerId = selectedPartnerId {
                            familyStore.shareDream(dreamId: dreamId, with: partnerId)
                        }
                        dismiss()
                    }
                    .disabled(selectedDreamId == nil || selectedPartnerId == nil)
                }
            }
        }
    }
}
