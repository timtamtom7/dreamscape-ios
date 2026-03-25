import SwiftUI

struct WaveformView: View {
    let levels: [CGFloat]
    let barCount: Int
    let isRecording: Bool

    init(levels: [CGFloat], barCount: Int = 30, isRecording: Bool = false) {
        self.levels = levels
        self.barCount = barCount
        self.isRecording = isRecording
    }

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<barCount, id: \.self) { index in
                WaveformBar(
                    level: index < levels.count ? levels[index] : 0,
                    isRecording: isRecording
                )
            }
        }
        .frame(height: 60)
    }
}

struct WaveformBar: View {
    let level: CGFloat
    let isRecording: Bool

    @State private var animatedLevel: CGFloat = 0

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(
                    colors: [
                        AppColors.auroraCyan,
                        AppColors.nebulaPink
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .frame(width: 4, height: max(4, 60 * animatedLevel))
            .animation(.spring(response: 0.1, dampingFraction: 0.5), value: animatedLevel)
            .onChange(of: level) { _, newValue in
                animatedLevel = newValue
            }
            .onAppear {
                animatedLevel = level
            }
    }
}

struct RecordingIndicator: View {
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(AppColors.error)
                .frame(width: 12, height: 12)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .opacity(isAnimating ? 0.7 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )

            Text("Recording")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    ZStack {
        AppColors.backgroundPrimary.ignoresSafeArea()
        VStack(spacing: 30) {
            WaveformView(
                levels: (0..<30).map { _ in CGFloat.random(in: 0.1...0.9) },
                isRecording: true
            )
            RecordingIndicator()
        }
        .padding()
    }
}
