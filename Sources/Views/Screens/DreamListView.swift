import SwiftUI

struct DreamListView: View {
    @EnvironmentObject var viewModel: JournalViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppColors.backgroundPrimary.ignoresSafeArea()

                if viewModel.dreams.isEmpty {
                    emptyState
                } else {
                    dreamList
                }

                // Floating action button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        floatingActionButton
                            .padding(.trailing, 24)
                            .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Dreams")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $viewModel.showingEntrySheet) {
                DreamEntryView()
            }
            .refreshable {
                await viewModel.refreshDreams()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Image(systemName: "moon.stars")
                .font(.system(size: 64))
                .foregroundColor(AppColors.auroraCyan.opacity(0.6))

            VStack(spacing: 8) {
                Text("Your dreams await...")
                    .font(AppFonts.titleSmall)
                    .foregroundColor(AppColors.textPrimary)

                Text("Tap the + button to record your first dream")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }

    private var dreamList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.dreams) { dream in
                    NavigationLink(destination: DreamDetailView(dream: dream)) {
                        DreamCard(dream: dream)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }

    private var floatingActionButton: some View {
        Button(action: {
            viewModel.showingEntrySheet = true
        }) {
            ZStack {
                Circle()
                    .fill(AppColors.auroraCyan)
                    .frame(width: 56, height: 56)
                    .shadow(color: AppColors.auroraCyan.opacity(0.5), radius: 10, x: 0, y: 4)

                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundColor(AppColors.backgroundPrimary)
            }
        }
    }
}

#Preview {
    DreamListView()
        .environmentObject(JournalViewModel())
}
