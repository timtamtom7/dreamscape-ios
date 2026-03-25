import SwiftUI

struct DreamEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: JournalViewModel

    @State private var entryMode: EntryMode = .voice
    @State private var typedContent = ""
    @State private var isRecording = false
    @State private var isSaving = false
    @State private var showDiscardAlert = false
    @State private var speechService = SpeechService()

    enum EntryMode: String, CaseIterable {
        case voice = "Voice"
        case typed = "Type"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Mode picker
                    Picker("Entry Mode", selection: $entryMode) {
                        ForEach(EntryMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    if entryMode == .voice {
                        voiceEntryView
                    } else {
                        typedEntryView
                    }

                    Spacer()

                    // Save button
                    if canSave {
                        GlowingButton(title: "Save Dream", icon: "sparkles") {
                            saveDream()
                        }
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("New Dream")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.backgroundPrimary, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        if hasContent {
                            showDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
            }
            .alert("Discard Dream?", isPresented: $showDiscardAlert) {
                Button("Discard", role: .destructive) {
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) {}
            } message: {
                Text("Your dream entry will be lost.")
            }
        }
    }

    private var voiceEntryView: some View {
        VStack(spacing: 32) {
            if speechService.isRecording {
                // Recording in progress
                VStack(spacing: 16) {
                    RecordingIndicator()

                    WaveformView(
                        levels: speechService.audioLevels,
                        isRecording: true
                    )

                    Text(speechService.transcribedText.isEmpty ? "Listening..." : speechService.transcribedText)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .frame(maxHeight: 200)
                }

                Button(action: stopRecording) {
                    ZStack {
                        Circle()
                            .fill(AppColors.error)
                            .frame(width: 72, height: 72)

                        Image(systemName: "stop.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
            } else {
                // Ready to record
                VStack(spacing: 16) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.auroraCyan)

                    Text("Tap to start recording")
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Text("Speak your dream aloud")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                }

                Button(action: startRecording) {
                    ZStack {
                        Circle()
                            .fill(AppColors.auroraCyan)
                            .frame(width: 72, height: 72)

                        Image(systemName: "mic.fill")
                            .font(.title)
                            .foregroundColor(AppColors.backgroundPrimary)
                    }
                }

                if !speechService.transcribedText.isEmpty {
                    VStack(spacing: 8) {
                        Text("Transcription:")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textMuted)

                        Text(speechService.transcribedText)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(AppColors.surface)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.top, 32)
    }

    private var typedEntryView: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .topLeading) {
                if typedContent.isEmpty {
                    Text("Describe your dream...")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textMuted)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 12)
                }

                TextEditor(text: $typedContent)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 200)
            }
            .padding()
            .background(AppColors.surface)
            .cornerRadius(16)
            .padding(.horizontal)

            Text("\(typedContent.count) / 5000 characters")
                .font(AppFonts.caption)
                .foregroundColor(typedContent.count > 4500 ? AppColors.warning : AppColors.textMuted)
                .padding(.trailing)
        }
    }

    private var hasContent: Bool {
        !typedContent.trimmed.isEmpty || !speechService.transcribedText.isEmpty
    }

    private var canSave: Bool {
        if entryMode == .voice {
            return !speechService.transcribedText.isEmpty && !isSaving
        } else {
            return !typedContent.trimmed.isEmpty && !isSaving
        }
    }

    private func startRecording() {
        Task {
            do {
                try await speechService.startRecording()
            } catch {
                print("Recording error: \(error)")
            }
        }
    }

    private func stopRecording() {
        speechService.stopRecording()
    }

    private func saveDream() {
        isSaving = true

        let content = entryMode == .voice ? speechService.transcribedText : typedContent

        Task {
            await viewModel.saveDream(content: content)
            await MainActor.run {
                isSaving = false
                dismiss()
            }
        }
    }
}

#Preview {
    DreamEntryView()
        .environmentObject(JournalViewModel())
}
