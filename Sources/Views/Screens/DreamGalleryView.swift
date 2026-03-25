import SwiftUI

/// R3: Dream Gallery — beautiful grid of AI-generated dream art
struct DreamGalleryView: View {
    @EnvironmentObject var viewModel: GalleryViewModel
    @State private var selectedDream: Dream?
    @State private var showingSleepCorrelation = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                if viewModel.isLoading {
                    loadingState
                } else if viewModel.galleryItems.isEmpty {
                    emptyState
                } else {
                    galleryContent
                }
            }
            .navigationTitle("Dream Gallery")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingSleepCorrelation = true }) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(AppColors.auroraCyan)
                    }
                }
            }
            .sheet(item: $selectedDream) { dream in
                DreamArtDetailView(dream: dream)
            }
            .sheet(isPresented: $showingSleepCorrelation) {
                SleepCorrelationView()
            }
            .onAppear {
                viewModel.loadGallery()
            }
        }
    }

    private var loadingState: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(AppColors.auroraCyan)
            Text("Generating your gallery...")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            CosmicDreamIllustration(size: 200)
                .padding(.top, 40)

            VStack(spacing: 8) {
                Text("Your dream gallery awaits")
                    .font(AppFonts.titleSmall)
                    .foregroundColor(AppColors.textPrimary)

                Text("Record dreams to generate unique abstract art for each one")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }

    private var galleryContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Stats row
                statsRow
                    .padding(.horizontal)

                // Gallery grid
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.galleryItems) { item in
                        GalleryArtCard(item: item) {
                            selectedDream = item.dream
                        }
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 100)
            }
            .padding(.top, 8)
        }
    }

    private var statsRow: some View {
        HStack(spacing: 16) {
            StatCard(
                icon: "photo.stack",
                value: "\(viewModel.galleryItems.count)",
                label: "Artworks"
            )

            StatCard(
                icon: "sparkles",
                value: "\(viewModel.totalSymbols)",
                label: "Symbols"
            )

            StatCard(
                icon: "chart.line.uptrend.xyaxis",
                value: viewModel.correlationScore,
                label: "Sleep Score"
            )
        }
    }
}

// MARK: - Gallery Item

struct GalleryItem: Identifiable {
    let id: UUID
    let dream: Dream
    let art: DreamArt?

    init(dream: Dream, art: DreamArt? = nil) {
        self.id = dream.id
        self.dream = dream
        self.art = art
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(AppColors.auroraCyan)

            Text(value)
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textPrimary)

            Text(label)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppColors.surface)
        .cornerRadius(12)
    }
}

// MARK: - Gallery Art Card

struct GalleryArtCard: View {
    let item: GalleryItem
    let onTap: () -> Void

    @State private var isAppearing = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Art preview
                GeometryReader { geometry in
                    DreamArtView(
                        dream: item.dream,
                        style: item.art?.style ?? .abstract,
                        size: geometry.size
                    )
                }
                .frame(height: 160)
                .clipped()

                // Info bar
                HStack {
                    Text(item.dream.shortFormattedDate)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)

                    Spacer()

                    if let mood = item.dream.mood {
                        Image(systemName: mood.icon)
                            .font(.caption2)
                            .foregroundColor(mood.color)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(AppColors.surface)
            }
            .background(AppColors.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.cardGlow, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isAppearing ? 1 : 0.9)
        .opacity(isAppearing ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double.random(in: 0...0.3))) {
                isAppearing = true
            }
        }
    }
}

// MARK: - Dream Art Detail View

struct DreamArtDetailView: View {
    let dream: Dream
    @Environment(\.dismiss) private var dismiss
    @State private var artStyle: DreamArtStyle = .abstract
    @State private var showShareSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Style picker
                        stylePicker

                        // Large art display
                        artDisplay
                            .frame(height: 350)
                            .cornerRadius(20)
                            .padding(.horizontal)

                        // Dream info
                        dreamInfoCard
                            .padding(.horizontal)

                        // Symbol palette
                        if !dream.symbols.isEmpty {
                            symbolPaletteCard
                                .padding(.horizontal)
                        }

                        // Emotional palette
                        if !dream.emotionalTags.isEmpty {
                            emotionalPaletteCard
                                .padding(.horizontal)
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Dream Art")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(AppColors.auroraCyan)
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(AppColors.auroraCyan)
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                DreamShareCardView(dream: dream)
            }
        }
    }

    private var stylePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                StyleButton(style: .abstract, selected: artStyle == .abstract) { artStyle = .abstract }
                StyleButton(style: .ethereal, selected: artStyle == .ethereal) { artStyle = .ethereal }
                StyleButton(style: .cosmic, selected: artStyle == .cosmic) { artStyle = .cosmic }
                StyleButton(style: .fluid, selected: artStyle == .fluid) { artStyle = .fluid }
                StyleButton(style: .geometric, selected: artStyle == .geometric) { artStyle = .geometric }
            }
            .padding(.horizontal)
        }
    }

    private var artDisplay: some View {
        GeometryReader { geometry in
            ZStack {
                DreamArtView(dream: dream, style: artStyle, size: geometry.size)

                // Overlay gradient for text readability
                VStack {
                    Spacer()
                    LinearGradient(
                        colors: [.clear, AppColors.backgroundPrimary.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 60)
                }
            }
        }
    }

    private var dreamInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dream.formattedDate)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.auroraCyan)

                if let mood = dream.mood {
                    HStack(spacing: 4) {
                        Image(systemName: mood.icon)
                            .font(.caption2)
                        Text(mood.displayName)
                            .font(AppFonts.caption)
                    }
                    .foregroundColor(mood.color)
                }

                Spacer()

                Text(artStyle.displayName)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textMuted)
            }

            Text(dream.summary.isEmpty ? dream.content.truncated(to: 150) : dream.summary)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(3)
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    private var symbolPaletteCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(AppColors.starGold)
                Text("Symbol Palette")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            FlowLayout(spacing: 8) {
                ForEach(dream.symbols.prefix(8)) { symbol in
                    HStack(spacing: 4) {
                        Image(systemName: symbol.category.icon)
                            .font(.caption2)
                        Text(symbol.name)
                            .font(AppFonts.callout)
                    }
                    .foregroundColor(symbol.category.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(symbol.category.color.opacity(0.15))
                    .cornerRadius(999)
                }
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(16)
    }

    private var emotionalPaletteCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(AppColors.nebulaPink)
                Text("Emotional Palette")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            FlowLayout(spacing: 8) {
                ForEach(dream.emotionalTags, id: \.self) { tag in
                    Text(tag)
                        .font(AppFonts.callout)
                        .foregroundColor(AppColors.nebulaPink)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppColors.nebulaPink.opacity(0.15))
                        .cornerRadius(999)
                }
            }
        }
        .padding(16)
        .background(AppColors.surface)
        .cornerRadius(16)
    }
}

// MARK: - Style Button

struct StyleButton: View {
    let style: DreamArtStyle
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(style.displayName)
                .font(AppFonts.callout)
                .foregroundColor(selected ? AppColors.backgroundPrimary : AppColors.textSecondary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(selected ? AppColors.auroraCyan : AppColors.surface)
                )
        }
    }
}

#Preview {
    DreamGalleryView()
        .environmentObject(GalleryViewModel())
}
