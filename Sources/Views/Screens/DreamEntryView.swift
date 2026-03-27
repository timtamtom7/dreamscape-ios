import SwiftUI
import PhotosUI

@MainActor
struct DreamEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: JournalViewModel

    @State private var entryMode: EntryMode = .voice
    @State private var typedContent = ""
    @State private var isRecording = false
    @State private var isSaving = false
    @State private var showDiscardAlert = false
    @State private var speechService = SpeechService()

    // R2: Enhanced fields
    @State private var selectedMood: MoodTag?
    @State private var isLucid = false
    @State private var attachedPhotoItem: PhotosPickerItem?
    @State private var attachedImageData: Data?
    @State private var showMoodPicker = false
    @State private var photoLoadError: String?
    @State private var showPhotoErrorAlert = false

    enum EntryMode: String, CaseIterable {
        case voice = "Voice"
        case typed = "Type"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // R2: Animated star field background
                StarFieldBackground(starCount: 120)
                    .opacity(0.6)

                // Parallax star layer
                StarFieldBackground(starCount: 60)
                    .opacity(0.3)
                    .offset(y: -20)

                AppColors.backgroundPrimary.opacity(0.85)
                    .ignoresSafeArea()

                ScrollView {
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

                        // R2: Mood picker section
                        moodPickerSection

                        // R2: Lucid dreaming toggle
                        lucidToggleSection

                        // R2: Photo attachment
                        photoAttachmentSection

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
            }
            .navigationTitle("New Dream")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.backgroundPrimary.opacity(0.9), for: .navigationBar)
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
            .alert("Photo Error", isPresented: $showPhotoErrorAlert) {
                Button("OK", role: .cancel) {
                    photoLoadError = nil
                    attachedImageData = nil
                    attachedPhotoItem = nil
                }
            } message: {
                Text(photoLoadError ?? "Failed to load photo. Please try again.")
            }
            .onChange(of: attachedPhotoItem) { _, newItem in
                Task { @MainActor in
                    photoLoadError = nil
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        attachedImageData = data
                    } else if newItem != nil {
                        photoLoadError = "Failed to load photo. The file may be corrupted or in an unsupported format."
                        showPhotoErrorAlert = true
                    }
                }
            }
        }
    }

    // MARK: - Voice Entry

    private var voiceEntryView: some View {
        VStack(spacing: 32) {
            if speechService.isRecording {
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

                Button(action: {
                    HapticFeedback.medium()
                    stopRecording()
                }) {
                    ZStack {
                        Circle()
                            .fill(AppColors.error)
                            .frame(width: 72, height: 72)

                        Image(systemName: "stop.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .accessibilityLabel("Stop recording")
                .accessibilityHint("Double tap to stop recording your dream")
            } else {
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

                Button(action: {
                    HapticFeedback.medium()
                    startRecording()
                }) {
                    ZStack {
                        Circle()
                            .fill(AppColors.auroraCyan)
                            .frame(width: 72, height: 72)

                        Image(systemName: "mic.fill")
                            .font(.title)
                            .foregroundColor(AppColors.backgroundPrimary)
                    }
                }
                .accessibilityLabel("Start voice recording")
                .accessibilityHint("Double tap to start recording your dream")

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
                            .background(AppColors.surface.opacity(0.8))
                            .cornerRadius(DesignTokens.CornerRadius.medium)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.top, 32)
    }

    // MARK: - Typed Entry

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
            .background(AppColors.surface.opacity(0.8))
            .cornerRadius(16)
            .padding(.horizontal)

            Text("\(typedContent.count) / 5000 characters")
                .font(AppFonts.caption)
                .foregroundColor(typedContent.count > 4500 ? AppColors.warning : AppColors.textMuted)
                .padding(.trailing)
        }
    }

    // MARK: - R2: Mood Picker

    private var moodPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood")
                .font(AppFonts.captionBold)
                .foregroundColor(AppColors.textMuted)
                .textCase(.uppercase)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(MoodTag.allCases) { mood in
                        MoodChip(
                            mood: mood,
                            isSelected: selectedMood == mood,
                            onTap: {
                                if selectedMood == mood {
                                    selectedMood = nil
                                } else {
                                    selectedMood = mood
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - R2: Lucid Toggle

    private var lucidToggleSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Lucid Dreaming")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)

                Text("Were you aware you were dreaming?")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            Toggle("", isOn: $isLucid)
                .labelsHidden()
                .tint(AppColors.nebulaPink)
        }
        .padding()
        .background(AppColors.surface.opacity(0.8))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    // MARK: - R2: Photo Attachment

    @ViewBuilder
    private var photoPickerButtonContentView: some View {
        HStack(spacing: 8) {
            Image(systemName: attachedImageData == nil ? "camera.fill" : "camera.fill.badge.checkmark")
                .foregroundColor(attachedImageData == nil ? AppColors.auroraCyan : AppColors.success)
            Text(attachedImageData == nil ? "Add Photo" : "Photo Added")
                .font(AppFonts.callout)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AppColors.surface.opacity(0.8))
        .cornerRadius(DesignTokens.CornerRadius.medium)
    }

    private var photoAttachmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Attach Photo (optional)")
                .font(AppFonts.captionBold)
                .foregroundColor(AppColors.textMuted)
                .textCase(.uppercase)
                .padding(.horizontal)

            HStack(spacing: 12) {
                PhotosPicker(selection: $attachedPhotoItem, matching: .images) {
                    photoPickerButtonContentView
                }

                if attachedImageData != nil {
                    Button(action: { attachedImageData = nil; attachedPhotoItem = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.error)
                    }
                }

                if photoLoadError != nil {
                    Button(action: {
                        photoLoadError = nil
                        attachedImageData = nil
                        attachedPhotoItem = nil
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .font(.caption2)
                            Text("Retry")
                                .font(AppFonts.caption)
                        }
                        .foregroundColor(AppColors.warning)
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Helpers

    private var hasContent: Bool {
        !typedContent.trimmed.isEmpty || !speechService.transcribedText.isEmpty || attachedImageData != nil
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
            await viewModel.saveDream(
                content: content,
                mood: selectedMood,
                isLucid: isLucid,
                photoData: attachedImageData
            )
            await MainActor.run {
                isSaving = false
                dismiss()
            }
        }
    }
}

// MARK: - Mood Chip

struct MoodChip: View {
    let mood: MoodTag
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            HapticFeedback.selection()
            onTap()
        }) {
            HStack(spacing: 6) {
                Image(systemName: mood.icon)
                    .font(AppFonts.caption)
                Text(mood.displayName)
                    .font(AppFonts.callout)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? mood.color.opacity(0.3) : AppColors.surface)
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? mood.color : Color.clear, lineWidth: 1.5)
            )
            .foregroundColor(isSelected ? mood.color : AppColors.textSecondary)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(mood.displayName) mood")
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(isSelected ? "Double tap to deselect" : "Double tap to select")
    }
}

#Preview {
    DreamEntryView()
        .environmentObject(JournalViewModel())
}
