import SwiftUI
import SwiftData

struct ContentView: View {

    @State private var timerService = LiveActivityService.shared
    @State private var router = DeepLinkRouter.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $router.selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Начало", systemImage: "house.fill")
                    }
                    .tag(0)

                ActivitiesListView()
                    .tabItem {
                        Label("Тренировки", systemImage: "dumbbell.fill")
                    }
                    .tag(1)

                MealsListView()
                    .tabItem {
                        Label("Хранене", systemImage: "fork.knife")
                    }
                    .tag(2)

                RemindersListView()
                    .tabItem {
                        Label("Навици", systemImage: "checkmark.circle")
                    }
                    .tag(3)

                SettingsView()
                    .tabItem {
                        Label("Настройки", systemImage: "gearshape.fill")
                    }
                    .tag(4)
            }
            .tint(AppTheme.accent)

            if timerService.isRunning {
                TimerBarView()
                    .padding(.horizontal, 12)
                    .padding(.bottom, 52)
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

struct TimerBarView: View {

    @State private var timerService = LiveActivityService.shared

    var body: some View {
        Button {
            timerService.showExpandedTimer = true
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 3)
                        .frame(width: 36, height: 36)

                    if !timerService.isPaused, let _ = timerService.endTime {
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

                if timerService.isPaused {
                    Text(timerService.remainingAtPause.formattedAsTime)
                        .font(.body.monospacedDigit().weight(.bold))
                        .foregroundStyle(.white)
                } else if let end = timerService.endTime {
                    Text(timerInterval: Date.now...end, countsDown: true)
                        .font(.body.monospacedDigit().weight(.bold))
                        .foregroundStyle(.white)
                }

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

}

#Preview {
    ContentView()
        .modelContainer(for: [
            Reminder.self, ReminderEntry.self,
            Activity.self, ActivitySession.self,
            Meal.self
        ], inMemory: true)
}
