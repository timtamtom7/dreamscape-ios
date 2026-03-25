import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: SettingsViewModel
    @State private var showTimePicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // Cloud Sync Section
                        settingsSection(title: "Cloud Sync") {
                            Toggle(isOn: Binding(
                                get: { viewModel.settings.cloudSyncEnabled },
                                set: { viewModel.setCloudSyncEnabled($0) }
                            )) {
                                HStack(spacing: 12) {
                                    Image(systemName: "icloud.fill")
                                        .foregroundColor(AppColors.auroraCyan)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Enable Cloud Sync")
                                            .font(AppFonts.body)
                                            .foregroundColor(AppColors.textPrimary)
                                        Text("Sync dreams across devices with E2E encryption")
                                            .font(AppFonts.caption)
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                            }
                            .tint(AppColors.auroraCyan)

                            if viewModel.settings.cloudSyncEnabled {
                                HStack {
                                    Text("Status")
                                        .font(AppFonts.body)
                                        .foregroundColor(AppColors.textSecondary)
                                    Spacer()
                                    Text(CloudSyncService.shared.isCloudAvailable ? "Connected" : "Unavailable")
                                        .font(AppFonts.body)
                                        .foregroundColor(
                                            CloudSyncService.shared.isCloudAvailable ? AppColors.success : AppColors.textMuted
                                        )
                                }
                            }
                        }

                        // Notifications Section
                        settingsSection(title: "Notifications") {
                            Toggle(isOn: Binding(
                                get: { viewModel.settings.morningPromptEnabled },
                                set: { newValue in
                                    if newValue {
                                        Task {
                                            await viewModel.requestNotificationPermission()
                                        }
                                    } else {
                                        viewModel.settings.morningPromptEnabled = false
                                    }
                                }
                            )) {
                                HStack(spacing: 12) {
                                    Image(systemName: "bell.fill")
                                        .foregroundColor(AppColors.nebulaPink)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Morning Dream Prompt")
                                            .font(AppFonts.body)
                                            .foregroundColor(AppColors.textPrimary)
                                        Text("Get reminded to log your dreams")
                                            .font(AppFonts.caption)
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                            }
                            .tint(AppColors.nebulaPink)

                            if viewModel.settings.morningPromptEnabled {
                                Button(action: { showTimePicker = true }) {
                                    HStack {
                                        Text("Reminder Time")
                                            .font(AppFonts.body)
                                            .foregroundColor(AppColors.textPrimary)
                                        Spacer()
                                        Text(viewModel.settings.morningPromptTime.formatted(date: .omitted, time: .shortened))
                                            .font(AppFonts.body)
                                            .foregroundColor(AppColors.auroraCyan)
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(AppColors.textMuted)
                                    }
                                }

                                if showTimePicker {
                                    DatePicker(
                                        "",
                                        selection: Binding(
                                            get: { viewModel.settings.morningPromptTime },
                                            set: { viewModel.setMorningPromptTime($0) }
                                        ),
                                        displayedComponents: .hourAndMinute
                                    )
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                                }
                            }
                        }

                        // Appearance Section
                        settingsSection(title: "Appearance") {
                            ForEach(AppTheme.allCases) { theme in
                                Button(action: { viewModel.setTheme(theme) }) {
                                    HStack {
                                        Text(theme.displayName)
                                            .font(AppFonts.body)
                                            .foregroundColor(AppColors.textPrimary)
                                        Spacer()
                                        if viewModel.settings.selectedTheme == theme {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(AppColors.auroraCyan)
                                        }
                                    }
                                }
                            }
                        }

                        // About Section
                        settingsSection(title: "About") {
                            HStack {
                                Text("Version")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                                Text("1.0.0")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textSecondary)
                            }

                            Link(destination: URL(string: "https://dreamscape.app/privacy")!) {
                                HStack {
                                    Text("Privacy Policy")
                                        .font(AppFonts.body)
                                        .foregroundColor(AppColors.textPrimary)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption)
                                        .foregroundColor(AppColors.textMuted)
                                }
                            }

                            HStack {
                                Text("Made with")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textSecondary)
                                Image(systemName: "heart.fill")
                                    .foregroundColor(AppColors.nebulaPink)
                                    .font(.caption)
                                Text("&")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textSecondary)
                                Image(systemName: "moon.stars.fill")
                                    .foregroundColor(AppColors.auroraCyan)
                                    .font(.caption)
                            }
                        }

                        Spacer(minLength: 100)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(AppFonts.captionBold)
                .foregroundColor(AppColors.textMuted)
                .textCase(.uppercase)

            VStack(spacing: 16) {
                content()
            }
            .padding(16)
            .background(AppColors.surface)
            .cornerRadius(16)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
}
