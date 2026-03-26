import SwiftUI
import SwiftData

/// Root view with tab bar + floating timer bar when a session is active.
struct ContentView: View {

    @State private var timerService = LiveActivityService.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Начало", systemImage: "house.fill")
                    }

                RemindersListView()
                    .tabItem {
                        Label("Напомняния", systemImage: "checkmark.circle")
                    }

                ActivitiesListView()
                    .tabItem {
                        Label("Активности", systemImage: "timer")
                    }

                ProgressOverviewView()
                    .tabItem {
                        Label("Прогрес", systemImage: "chart.line.uptrend.xyaxis")
                    }

                SettingsView()
                    .tabItem {
                        Label("Настройки", systemImage: "gearshape.fill")
                    }
            }
            .tint(.blue)

            // Floating timer bar above the tab bar
            if timerService.isRunning {
                TimerBarView()
                    .padding(.horizontal, 12)
                    .padding(.bottom, 52) // sits above the tab bar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(duration: 0.3), value: timerService.isRunning)
            }
        }
        .sheet(isPresented: $timerService.showExpandedTimer) {
            ActiveTimerView()
        }
    }
}

// MARK: - Floating Timer Bar

/// A compact bar showing the running timer. Tappable to expand.
struct TimerBarView: View {

    @State private var timerService = LiveActivityService.shared

    var body: some View {
        Button {
            timerService.showExpandedTimer = true
        } label: {
            HStack(spacing: 12) {
                // Animated circle
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 3)
                        .frame(width: 36, height: 36)

                    if !timerService.isPaused, let end = timerService.endTime {
                        Circle()
                            .trim(from: 0, to: timerProgress)
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 36, height: 36)
                            .rotationEffect(.degrees(-90))
                    }

                    Image(systemName: timerService.activityIcon)
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                }

                // Activity name
                VStack(alignment: .leading, spacing: 2) {
                    Text(timerService.activityName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)

                    if timerService.isPaused {
                        Text("На пауза")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }

                Spacer()

                // Countdown
                if timerService.isPaused {
                    Text(formatSeconds(timerService.remainingAtPause))
                        .font(.body.monospacedDigit().weight(.bold))
                        .foregroundStyle(.white)
                } else if let end = timerService.endTime {
                    Text(timerInterval: Date.now...end, countsDown: true)
                        .font(.body.monospacedDigit().weight(.bold))
                        .foregroundStyle(.white)
                }

                // Quick stop button
                Button {
                    timerService.endSession()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .frame(width: 28, height: 28)
                        .background(.white.opacity(0.2), in: Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Color(hex: timerService.activityColorHex).gradient,
                in: RoundedRectangle(cornerRadius: 20)
            )
            .shadow(color: Color(hex: timerService.activityColorHex).opacity(0.4), radius: 8, y: 4)
        }
    }

    private var timerProgress: Double {
        guard let end = timerService.endTime, timerService.totalDuration > 0 else { return 0 }
        let remaining = end.timeIntervalSinceNow
        return max(0, remaining / Double(timerService.totalDuration))
    }

    private func formatSeconds(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            Reminder.self, ReminderEntry.self,
            Activity.self, ActivitySession.self
        ], inMemory: true)
}
