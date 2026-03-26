import SwiftUI

/// R14: Vision Pro spatial dream gallery
/// Immersive environments for dreaming
struct DreamSpatialGalleryView: View {
    @EnvironmentObject var viewModel: JournalViewModel
    @State private var selectedDream: Dream?
    @State private var showingImmersiveEnvironment = false

    var body: some View {
        ZStack {
            // Spatial grid of dreams
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                    ForEach(viewModel.dreams) { dream in
                        DreamSpatialCard(dream: dream)
                            .onTapGesture {
                                selectedDream = dream
                            }
                    }
                }
                .padding()
            }

            // Selected dream detail
            if let dream = selectedDream {
                dreamDetailOverlay(dream)
            }
        }
        .sheet(isPresented: $showingImmersiveEnvironment) {
            if let dream = selectedDream {
                ImmersiveDreamEnvironmentView(dream: dream)
            }
        }
    }

    private func dreamDetailOverlay(_ dream: Dream) -> some View {
        VStack {
            Spacer()

            HStack {
                Spacer()

                VStack(alignment: .trailing, spacing: 12) {
                    Text(dream.summary.isEmpty ? dream.content.prefix(50).description : dream.summary)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(2)

                    Text(dream.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack {
                        if dream.isLucid {
                            Label("Lucid", systemImage: "sparkles")
                                .font(.caption)
                                .foregroundColor(.purple)
                        }

                        Button {
                            showingImmersiveEnvironment = true
                        } label: {
                            Label("Immerse", systemImage: "view.3d")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .padding()

                Spacer()
            }
        }
    }
}

struct DreamSpatialCard: View {
    let dream: Dream

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Dream color based on mood/theme
            RoundedRectangle(cornerRadius: 12)
                .fill(dreamGradient)
                .frame(height: 100)
                .overlay {
                    VStack {
                        if dream.isLucid {
                            Image(systemName: "sparkles")
                                .foregroundColor(.white)
                        }
                        Text(dream.summary.isEmpty ? String(dream.content.prefix(30)) : String(dream.summary.prefix(30)))
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                }

            Text(dream.createdAt.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(8)
        .background(Color(.systemBackground).opacity(0.1))
        .cornerRadius(16)
    }

    private var dreamGradient: LinearGradient {
        let colors: [Color] = {
            switch dream.mood {
            case .peaceful: return [.blue, .purple]
            case .anxious: return [.orange, .red]
            case .dark: return [.purple, .black]
            case .confusing: return [.gray, .blue]
            case .exhilarating: return [.yellow, .orange]
            case .mysterious: return [.cyan, .mint]
            case .joyful: return [.yellow, .green]
            case .melancholy: return [.blue, .gray]
            case .none: return [.gray, .blue]
            }
        }()
        return LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

/// R14: Immersive dream environment for Vision Pro
struct ImmersiveDreamEnvironmentView: View {
    @Environment(\.dismiss) private var dismiss
    let dream: Dream

    var body: some View {
        ZStack {
            LinearGradient(
                colors: dreamGradientColors,
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Text(dream.summary.isEmpty ? "Dream" : dream.summary)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(dream.content)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                Button("Return") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 40)
            }
            .padding(.top, 60)
        }
    }

    private var dreamGradientColors: [Color] {
        switch dream.mood {
        case .peaceful: return [Color(hex: "1A1A2E"), Color(hex: "16213E"), Color(hex: "0F3460")]
        case .anxious: return [Color(hex: "2C0000"), Color(hex: "5C0001"), Color(hex: "8B0000")]
        case .dark: return [Color(hex: "1A001A"), Color(hex: "330033"), Color(hex: "4B0082")]
        case .confusing: return [Color(hex: "1A1A1A"), Color(hex: "2E2E2E"), Color(hex: "3A3A3A")]
        case .exhilarating: return [Color(hex: "2C2C00"), Color(hex: "5C5C00"), Color(hex: "8B8B00")]
        case .mysterious: return [Color(hex: "003333"), Color(hex: "006666"), Color(hex: "00CCCC")]
        case .joyful: return [Color(hex: "1A2C00"), Color(hex: "3C5C00"), Color(hex: "5C8B00")]
        case .melancholy: return [Color(hex: "1A1A2E"), Color(hex: "2E2E4E"), Color(hex: "3A3A6E")]
        case .none: return [Color(hex: "1A1A1A"), Color(hex: "2E2E2E"), Color(hex: "3A3A3A")]
        }
    }
}
