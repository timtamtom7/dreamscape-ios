import SwiftUI

struct DreamGroupsView: View {
    @State private var selectedCommunity: Community?
    @State private var selectedTab: CommunityTab = .recent
    @State private var searchText: String = ""

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                // Community List
                List(Community.allCases, selection: $selectedCommunity) { community in
                    NavigationLink(value: community) {
                        CommunityRow(community: community)
                    }
                    .listRowBackground(Color.nsSurface)
                }
                .listStyle(.sidebar)
                .scrollContentBackground(.hidden)
                .background(Color.nsBackground)

                Divider()

                // Quick Stats
                HStack(spacing: 16) {
                    StatPill(icon: "person.3.fill", value: "2.4K", label: "Dreamers")
                    StatPill(icon: "moon.stars.fill", value: "12K", label: "Dreams Shared")
                }
                .padding()
            }
            .background(Color.nsBackground)
            .navigationTitle("Dream Communities")
        } detail: {
            if let community = selectedCommunity {
                CommunityDetailView(community: community, searchText: $searchText)
            } else {
                ContentUnavailableView(
                    "Select a Community",
                    systemImage: "person.3",
                    description: Text("Choose a dream community from the sidebar to explore shared dreams")
                )
            }
        }
    }
}

// MARK: - Community Model

enum Community: String, CaseIterable, Identifiable {
    case dreamInterpreters = "Dream Interpreters"
    case lucidDreamers = "Lucid Dreamers"
    case symbolCollectors = "Symbol Collectors"
    case anonymousPool = "Anonymous Pool"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .dreamInterpreters: return "Share and interpret each other's dreams with the community"
        case .lucidDreamers: return "Tips and dreams from experienced lucid dreamers"
        case .symbolCollectors: return "Build the collective symbol database"
        case .anonymousPool: return "Browse all anonymously shared dreams"
        }
    }

    var icon: String {
        switch self {
        case .dreamInterpreters: return "brain.head.profile"
        case .lucidDreamers: return "sparkles"
        case .symbolCollectors: return "star.circle"
        case .anonymousPool: return "person.fill.questionmark"
        }
    }

    var color: Color {
        switch self {
        case .dreamInterpreters: return Color(hex: "C084FC")
        case .lucidDreamers: return Color(hex: "5EEAD4")
        case .symbolCollectors: return Color(hex: "FCD34D")
        case .anonymousPool: return Color(hex: "60A5FA")
        }
    }

    var memberCount: Int {
        switch self {
        case .dreamInterpreters: return 847
        case .lucidDreamers: return 1203
        case .symbolCollectors: return 562
        case .anonymousPool: return 0
        }
    }

    var dreamCount: Int {
        switch self {
        case .dreamInterpreters: return 3421
        case .lucidDreamers: return 5102
        case .symbolCollectors: return 1893
        case .anonymousPool: return 12403
        }
    }
}

// MARK: - Community Row

struct CommunityRow: View {
    let community: Community

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: community.icon)
                .font(.title2)
                .foregroundStyle(community.color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(community.rawValue)
                    .font(.headline)
                    .foregroundStyle(Color.nsTextPrimary)

                Text("\(community.memberCount.formatted()) members")
                    .font(.caption)
                    .foregroundStyle(Color.nsTextSecondary)
            }

            Spacer()

            if community != .anonymousPool {
                Text("\(community.dreamCount.formatted()) dreams")
                    .font(.caption2)
                    .foregroundStyle(Color.nsTextMuted)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.nsSurface.opacity(0.5))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Community Detail View

struct CommunityDetailView: View {
    let community: Community
    @Binding var searchText: String
    @State private var selectedTab: CommunityTab = .recent
    @State private var dreams: [AnonymousDream] = []
    @State private var selectedDream: AnonymousDream?
    @State private var isLoading = false

    var filteredDreams: [AnonymousDream] {
        if searchText.isEmpty {
            return dreams
        }
        return dreams.filter {
            $0.summary.localizedCaseInsensitiveContains(searchText) ||
            $0.detectedSymbols.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: community.icon)
                        .font(.largeTitle)
                        .foregroundStyle(community.color)

                    VStack(alignment: .leading) {
                        Text(community.rawValue)
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text(community.description)
                            .font(.caption)
                            .foregroundStyle(Color.nsTextSecondary)
                    }

                    Spacer()

                    Button(action: {}) {
                        Label("Join", systemImage: "plus.circle.fill")
                            .font(.subheadline)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(community.color)
                }

                // Tab Selector
                HStack(spacing: 0) {
                    ForEach(CommunityTab.allCases) { tab in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                            }
                        } label: {
                            VStack(spacing: 4) {
                                Text(tab.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(selectedTab == tab ? .semibold : .regular)

                                Rectangle()
                                    .fill(selectedTab == tab ? community.color : Color.clear)
                                    .frame(height: 2)
                            }
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(selectedTab == tab ? community.color : Color.nsTextSecondary)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding()
            .background(Color.nsSurface)

            Divider()

            // Dream List
            if isLoading {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                Spacer()
            } else if filteredDreams.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredDreams) { dream in
                            SharedDreamCard(dream: dream, communityColor: community.color)
                                .onTapGesture {
                                    selectedDream = dream
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color.nsBackground)
        .task {
            await loadDreams()
        }
        .sheet(item: $selectedDream) { dream in
            DreamDetailSheet(dream: dream, communityColor: community.color)
        }
    }

    private func loadDreams() async {
        isLoading = true
        try? await Task.sleep(nanoseconds: 300_000_000)

        let tagMap: [Community: String] = [
            .dreamInterpreters: "dream-interpreters",
            .lucidDreamers: "lucid-dreamers",
            .symbolCollectors: "symbol-collectors",
            .anonymousPool: "general"
        ]

        dreams = DreamSharingService.shared.getAnonymousPool(tag: tagMap[community])
        isLoading = false
    }
}

// MARK: - Community Tab

enum CommunityTab: String, CaseIterable, Identifiable {
    case recent = "Recent"
    case popular = "Popular"
    case following = "Following"

    var id: String { rawValue }
}

// MARK: - Shared Dream Card

struct SharedDreamCard: View {
    let dream: AnonymousDream
    let communityColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                MoodBadge(mood: dream.mood)

                Spacer()

                HStack(spacing: 12) {
                    Label("\(dream.likes)", systemImage: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(Color.nsTextSecondary)

                    Label("\(dream.commentCount)", systemImage: "bubble.right")
                        .font(.caption)
                        .foregroundStyle(Color.nsTextSecondary)
                }
            }

            Text(dream.summary)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.nsTextPrimary)
                .lineLimit(2)

            Text(dream.narrativeSnippet + "...")
                .font(.caption)
                .foregroundStyle(Color.nsTextSecondary)
                .lineLimit(2)

            // Symbols
            HStack(spacing: 6) {
                ForEach(dream.detectedSymbols.prefix(4), id: \.self) { symbol in
                    SymbolPill(symbol: symbol)
                }

                if dream.detectedSymbols.count > 4 {
                    Text("+\(dream.detectedSymbols.count - 4)")
                        .font(.caption2)
                        .foregroundStyle(Color.nsTextMuted)
                }
            }

            HStack {
                LucidityBadge(level: dream.lucidityLevel)

                Spacer()

                Text(dream.sharedAt.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(Color.nsTextMuted)
            }
        }
        .padding()
        .background(Color.nsSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(communityColor.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Symbol Pill

struct SymbolPill: View {
    let symbol: String

    var body: some View {
        Text(symbol)
            .font(.caption2)
            .foregroundStyle(Color.nsTextPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.nsSurfaceElevated)
            .clipShape(Capsule())
    }
}

// MARK: - Mood Badge

struct MoodBadge: View {
    let mood: Dream.Mood

    var color: Color {
        Color(hex: mood.color)
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(mood.emoji)
            Text(mood.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.15))
        .clipShape(Capsule())
    }
}

// MARK: - Dream Detail Sheet

struct DreamDetailSheet: View {
    let dream: AnonymousDream
    let communityColor: Color
    @Environment(\.dismiss) private var dismiss
    @State private var commentText: String = ""
    @State private var comments: [DreamComment] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            MoodBadge(mood: dream.mood)
                            LucidityBadge(level: dream.lucidityLevel)
                            Spacer()
                        }

                        Text(dream.summary)
                            .font(.headline)
                            .foregroundStyle(Color.nsTextPrimary)
                    }

                    Divider()

                    // Narrative
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Dream")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.nsTextSecondary)

                        Text(dream.narrativeSnippet + "...")
                            .font(.body)
                            .foregroundStyle(Color.nsTextPrimary)
                    }

                    // Symbols
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Detected Symbols")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.nsTextSecondary)

                        FlowLayout(spacing: 8) {
                            ForEach(dream.detectedSymbols, id: \.self) { symbol in
                                SymbolPill(symbol: symbol)
                            }
                        }
                    }

                    Divider()

                    // Comments Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Interpretations (\(comments.count))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.nsTextSecondary)

                        ForEach(comments) { comment in
                            CommentRow(comment: comment)
                        }

                        // Add Comment
                        HStack {
                            TextField("Share your interpretation...", text: $commentText)
                                .textFieldStyle(.roundedBorder)

                            Button {
                                submitComment()
                            } label: {
                                Image(systemName: "paperplane.fill")
                            }
                            .disabled(commentText.isEmpty)
                        }
                    }
                }
                .padding()
            }
            .background(Color.nsBackground)
            .navigationTitle("Shared Dream")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            comments = DreamSharingService.shared.getComments(for: dream.dreamId)
        }
    }

    private func submitComment() {
        guard !commentText.isEmpty else { return }
        let comment = DreamSharingService.shared.addComment(to: dream.dreamId, content: commentText)
        comments.append(comment)
        commentText = ""
    }
}

// MARK: - Comment Row

struct CommentRow: View {
    let comment: DreamComment
    @State private var isLiked = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(comment.authorName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.nsAccentPrimary)

                Spacer()

                Text(comment.createdAt.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(Color.nsTextMuted)
            }

            Text(comment.content)
                .font(.subheadline)
                .foregroundStyle(Color.nsTextPrimary)

            HStack {
                Button {
                    isLiked.toggle()
                    if isLiked {
                        DreamSharingService.shared.likeComment(comment)
                    }
                } label: {
                    Label("\(comment.likes + (isLiked ? 1 : 0))", systemImage: isLiked ? "heart.fill" : "heart")
                        .font(.caption)
                        .foregroundStyle(isLiked ? .pink : Color.nsTextSecondary)
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
        .padding()
        .background(Color.nsSurface)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Stat Pill

struct StatPill: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color.nsAccentPrimary)

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.nsTextPrimary)

            Text(label)
                .font(.caption)
                .foregroundStyle(Color.nsTextSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.nsSurface)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
