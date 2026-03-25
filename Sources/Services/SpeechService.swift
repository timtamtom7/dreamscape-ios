import Foundation
import AVFoundation
import Speech

@MainActor
final class SpeechService: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var isTranscribing = false
    @Published var audioLevels: [CGFloat] = Array(repeating: 0, count: 30)
    @Published var transcribedText = ""
    @Published var errorMessage: String?

    private var audioRecorder: AVAudioRecorder?
    private var levelTimer: Timer?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

    override init() {
        super.init()
    }

    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    func startRecording() async throws {
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            throw SpeechError.notAuthorized
        }

        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw SpeechError.recognizerUnavailable
        }

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("dream_recording.m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
        audioRecorder?.isMeteringEnabled = true
        audioRecorder?.record()

        isRecording = true
        startLevelTimer()

        // Start transcription
        try await startTranscription()
    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        stopLevelTimer()

        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setActive(false)
    }

    private func startLevelTimer() {
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateAudioLevels()
            }
        }
    }

    private func stopLevelTimer() {
        levelTimer?.invalidate()
        levelTimer = nil
        audioLevels = Array(repeating: 0, count: 30)
    }

    private func updateAudioLevels() {
        guard let recorder = audioRecorder, recorder.isRecording else { return }

        recorder.updateMeters()
        let level = recorder.averagePower(forChannel: 0)
        let normalizedLevel = CGFloat(max(0, (level + 60) / 60))

        // Shift array and add new level
        audioLevels.removeFirst()
        audioLevels.append(normalizedLevel)
    }

    private func startTranscription() async throws {
        guard let speechRecognizer = speechRecognizer else {
            throw SpeechError.recognizerUnavailable
        }

        isTranscribing = true

        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentsPath.appendingPathComponent("dream_recording.m4a")

        let request = SFSpeechURLRecognitionRequest(url: audioFilename)
        request.shouldReportPartialResults = false

        if #available(iOS 16.0, *) {
            request.addsPunctuation = true
        }

        return try await withCheckedThrowingContinuation { continuation in
            speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
                Task { @MainActor in
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        self?.isTranscribing = false
                        continuation.resume(throwing: error)
                        return
                    }

                    if let result = result, result.isFinal {
                        self?.transcribedText = result.bestTranscription.formattedString
                        self?.isTranscribing = false
                        continuation.resume()
                    }
                }
            }
        }
    }

    func reset() {
        transcribedText = ""
        errorMessage = nil
        audioLevels = Array(repeating: 0, count: 30)
    }
}

enum SpeechError: LocalizedError {
    case notAuthorized
    case recognizerUnavailable
    case recordingFailed

    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Speech recognition not authorized. Please enable in Settings."
        case .recognizerUnavailable:
            return "Speech recognizer is not available."
        case .recordingFailed:
            return "Failed to start recording."
        }
    }
}
