import SwiftUI
import SwiftData
import Charts

struct HomeView: View {

    @Query(filter: #Predicate<Reminder> { $0.isActive }, sort: \Reminder.sortOrder)
    private var reminders: [Reminder]

    @Query(sort: \Activity.sortOrder)
    private var activities: [Activity]

    @Query(sort: \Meal.createdAt, order: .reverse)
    private var meals: [Meal]

    @Environment(\.modelContext) private var modelContext
    @AppStorage("userName") private var userName = ""
    @AppStorage("dailyCalorieGoal") private var dailyCalorieGoal = 2000
    @State private var showNameSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    greetingHeader
                    threePillarsCard
                    statsGrid
                    weeklyChart
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
        }
        .onAppear {
            if userName.isEmpty {
                showNameSheet = true
            }
        }
        .sheet(isPresented: $showNameSheet) {
            NameEntrySheet(userName: $userName)
        }
    }

    // MARK: - Greeting Header

    private var greetingHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.title2.bold())
                Text(Date(), format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            initialsAvatar
        }
    }

    private var greetingText: String {
        userName.isEmpty ? "Здравей!" : "Здравей, \(userName.components(separatedBy: " ").first ?? userName)!"
    }

    private var initialsAvatar: some View {
        ZStack {
            Circle()
                .fill(AppTheme.accent)
                .frame(width: 44, height: 44)

            if userName.isEmpty {
                Image(systemName: "person.fill")
                    .font(.body)
                    .foregroundStyle(.white)
            } else {
                Text(initials)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
            }
        }
    }

    private var initials: String {
        let parts = userName.components(separatedBy: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.count > 1 ? parts.last?.prefix(1) ?? "" : ""
        return "\(first)\(last)".uppercased()
    }

    // MARK: - Three Pillars

    private var threePillarsCard: some View {
        HStack(spacing: 16) {
            PillarRingView(
                title: "Тренировки",
                progress: trainingProgress,
                color: Color(hex: "#EF4444"),
                icon: "dumbbell.fill"
            )
            PillarRingView(
                title: "Хранене",
                progress: nutritionProgress,
                color: Color(hex: "#22C55E"),
                icon: "fork.knife"
            )
            PillarRingView(
                title: "Навици",
                progress: routinesProgress,
                color: Color(hex: "#3B82F6"),
                icon: "checkmark.circle"
            )
        }
        .padding()
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: AppTheme.cardRadius))
        .shadow(color: AppTheme.cardShadow, radius: AppTheme.cardShadowRadius, y: 2)
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(title: "Тренировки днес", value: "\(todaySessionsCount)", icon: "dumbbell.fill", color: Color(hex: "#EF4444"))
            StatCard(title: "Калории днес", value: "\(todayCalories)/\(dailyCalorieGoal)", icon: "fork.knife", color: Color(hex: "#22C55E"))
            StatCard(title: "Навици днес", value: "\(completedRemindersToday)/\(reminders.count)", icon: "checkmark.circle.fill", color: Color(hex: "#3B82F6"))
            StatCard(title: "Най-дълъг streak", value: "\(longestStreak)", icon: "flame.fill", color: .orange)
        }
    }

    // MARK: - Weekly Chart

    private var weeklyChart: some View {
        let weekData = lastSevenDaysData()

        return VStack(alignment: .leading, spacing: 12) {
            Text("Последните 7 дни")
                .font(.headline)

            Chart(weekData, id: \.date) { day in
                BarMark(
                    x: .value("Ден", day.date, unit: .day),
                    y: .value("Изпълнени", day.completedCount)
                )
                .foregroundStyle(AppTheme.accent.gradient)
                .cornerRadius(4)
            }
            .frame(height: 180)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: AppTheme.cardRadius))
        .shadow(color: AppTheme.cardShadow, radius: AppTheme.cardShadowRadius, y: 2)
    }

    // MARK: - Computed Data

    private var trainingProgress: Double {
        guard !activities.isEmpty else { return 0 }
        let todaySessions = activities.filter { activity in
            activity.sessions.contains { Calendar.current.isDateInToday($0.startedAt) && $0.isCompleted }
        }.count
        return min(Double(todaySessions) / Double(activities.count), 1.0)
    }

    private var nutritionProgress: Double {
        guard dailyCalorieGoal > 0 else { return 0 }
        return min(Double(todayCalories) / Double(dailyCalorieGoal), 1.0)
    }

    private var routinesProgress: Double {
        guard !reminders.isEmpty else { return 0 }
        let completed = reminders.filter(\.isCompletedToday).count
        return Double(completed) / Double(reminders.count)
    }

    private var todaySessionsCount: Int {
        activities.flatMap(\.sessions).filter {
            Calendar.current.isDateInToday($0.startedAt) && $0.isCompleted
        }.count
    }

    private var todayCalories: Int {
        meals.filter { Calendar.current.isDateInToday($0.createdAt) }
            .reduce(0) { $0 + $1.calories }
    }

    private var completedRemindersToday: Int {
        reminders.filter(\.isCompletedToday).count
    }

    private var longestStreak: Int {
        reminders.map(\.bestStreak).max() ?? 0
    }

    // MARK: - Weekly Data

    private struct DayStats {
        let date: Date
        let completedCount: Int
    }

    private func lastSevenDaysData() -> [DayStats] {
        let calendar = Calendar.current
        return (0..<7).reversed().compactMap { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) else { return nil }
            let startOfDay = calendar.startOfDay(for: date)
            let completed = reminders.filter { reminder in
                reminder.entries.contains { calendar.isDate($0.date, inSameDayAs: startOfDay) && $0.isCompleted }
            }.count
            return DayStats(date: startOfDay, completedCount: completed)
        }
    }
}

// MARK: - Calorie Calculator

enum CalorieCalculator {
    static func calculateGoal(weightKg: Int, goal: String, activity: String) -> Int {
        let baseBMR = weightKg * 24

        let multiplier: Double = switch activity {
        case "sedentary": 1.2
        case "active": 1.75
        default: 1.5
        }

        let maintenance = Int(Double(baseBMR) * multiplier)

        return switch goal {
        case "lose": maintenance - 400
        case "gain": maintenance + 400
        default: maintenance
        }
    }
}

// MARK: - Name Entry Sheet

struct NameEntrySheet: View {
    @Binding var userName: String
    @Environment(\.dismiss) private var dismiss

    @AppStorage("userWeight") private var userWeight = 70
    @AppStorage("fitnessGoal") private var fitnessGoal = "maintain"
    @AppStorage("activityLevel") private var activityLevel = "moderate"
    @AppStorage("dailyCalorieGoal") private var dailyCalorieGoal = 2000

    @State private var nameInput = ""
    @State private var weightText = "70"

    private let goals = ["lose", "maintain", "gain"]
    private let goalLabels = ["Отслабване", "Поддържане", "Качване"]
    private let activityLevels = ["sedentary", "moderate", "active"]
    private let activityLabels = ["Заседнал", "Умерен", "Активен"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "hand.wave.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(AppTheme.accent)

                    Text("Добре дошъл в DialedIn!")
                        .font(.title2.bold())

                    Text("Как да те наричаме?")
                        .font(.body)
                        .foregroundStyle(.secondary)

                    TextField("Вашето име", text: $nameInput)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.words)
                        .padding(.horizontal, 40)

                    Divider().padding(.horizontal, 40)

                    VStack(spacing: 16) {
                        Text("Твоите параметри")
                            .font(.headline)

                        HStack {
                            Text("Тегло")
                            Spacer()
                            TextField("кг", text: $weightText)
                                .keyboardType(.numberPad)
                                .frame(width: 60)
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.center)
                            Text("кг")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 40)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Цел")
                                .font(.subheadline.weight(.medium))
                            Picker("Цел", selection: $fitnessGoal) {
                                ForEach(Array(zip(goals, goalLabels)), id: \.0) { value, label in
                                    Text(label).tag(value)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.horizontal, 40)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Активност")
                                .font(.subheadline.weight(.medium))
                            Picker("Активност", selection: $activityLevel) {
                                ForEach(Array(zip(activityLevels, activityLabels)), id: \.0) { value, label in
                                    Text(label).tag(value)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.horizontal, 40)

                        Text("Дневна цел: \(computedGoal) kcal")
                            .font(.headline)
                            .foregroundStyle(AppTheme.accent)
                            .padding(.top, 8)
                    }

                    Button {
                        saveAndDismiss()
                    } label: {
                        Text("Запази")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 40)
                    .disabled(nameInput.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.vertical, 32)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Пропусни") { dismiss() }
                }
            }
        }
    }

    private var computedGoal: Int {
        let weight = Int(weightText) ?? 70
        return CalorieCalculator.calculateGoal(weightKg: weight, goal: fitnessGoal, activity: activityLevel)
    }

    private func saveAndDismiss() {
        userName = nameInput.trimmingCharacters(in: .whitespaces)
        userWeight = Int(weightText) ?? 70
        dailyCalorieGoal = computedGoal
        dismiss()
    }
}

// MARK: - Pillar Ring Component

struct PillarRingView: View {
    let title: String
    let progress: Double
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progress)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
            }
            .frame(width: 70, height: 70)

            Text("\(Int(progress * 100))%")
                .font(.caption.weight(.bold))
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.weight(.bold))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: AppTheme.cardShadow, radius: 6, y: 2)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [
            Reminder.self, ReminderEntry.self,
            Activity.self, ActivitySession.self,
            Meal.self
        ], inMemory: true)
}
