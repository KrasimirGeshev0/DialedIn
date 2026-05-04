import SwiftUI
import SwiftData

/// Expanded timer view -- shown as a sheet when tapping the timer bar.
/// Big countdown circle with pause/resume/stop controls.
struct ActiveTimerView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var timerService = LiveActivityService.shared
    @State private var errorMessage: String?

    // Find the running session to update it when stopped
    @Query(filter: #Predicate<ActivitySession> { $0.endedAt == nil })
    private var runningSessions: [ActivitySession]

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Activity icon and name
                Image(systemName: timerService.activityIcon)
                    .font(.system(size: 48))
                    .foregroundStyle(accentColor)

                Text(timerService.activityName)
                    .font(.title2.weight(.semibold))

                // Big countdown circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 14)

                    if !timerService.isPaused, timerService.endTime != nil {
                        Circle()
                            .trim(from: 0, to: timerProgress)
                            .stroke(
                                accentColor,
                                style: StrokeStyle(lineWidth: 14, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                    }

                    VStack(spacing: 8) {
                        if timerService.isPaused {
                            Text("ПАУЗА")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.orange)
                            Text(timerService.remainingAtPause.formattedAsTime)
                                .font(.system(size: 52, weight: .bold, design: .monospaced))
                        } else if let end = timerService.endTime {
                            Text(timerInterval: Date.now...end, countsDown: true)
                                .font(.system(size: 52, weight: .bold, design: .monospaced))
                                .monospacedDigit()
                        }
                    }
                }
                .frame(width: 240, height: 240)

                Spacer()

                // Controls
                HStack(spacing: 48) {
                    Button {
                        if timerService.isPaused {
                            timerService.resumeSession()
                        } else {
                            timerService.pauseSession()
                        }
                    } label: {
                        Image(systemName: timerService.isPaused ? "play.fill" : "pause.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 64, height: 64)
                            .background(accentColor, in: Circle())
                    }

                    Button {
                        stopSession()
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .frame(width: 64, height: 64)
                            .background(.red, in: Circle())
                    }
                }

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Затвори") { dismiss() }
                }
            }
        }
        .presentationDetents([.large])
        .alert("Грешка", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: - Helpers

    private var accentColor: Color {
        Color(hex: timerService.activityColorHex)
    }

    private var timerProgress: Double {
        guard let end = timerService.endTime, timerService.totalDuration > 0 else { return 0 }
        let remaining = end.timeIntervalSinceNow
        return max(0, remaining / Double(timerService.totalDuration))
    }

    private func stopSession() {
        if let session = runningSessions.first {
            session.finish(completed: true)
        }

        do {
            try modelContext.save()
        } catch {
            errorMessage = AppError.saveFailed(error.localizedDescription).localizedDescription
        }

        timerService.endSession()
        dismiss()
    }
}

#Preview {
    ActiveTimerView()
        .modelContainer(for: [Activity.self, ActivitySession.self], inMemory: true)
}
