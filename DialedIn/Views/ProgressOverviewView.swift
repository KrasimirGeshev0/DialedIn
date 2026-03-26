import SwiftUI
import SwiftData
import Charts

/// Progress overview across all reminders (and later activities).
struct ProgressOverviewView: View {

    @Query(filter: #Predicate<Reminder> { $0.isActive }) private var reminders: [Reminder]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    statsGrid
                    weeklyChart
                    streaksSection
                }
                .padding()
            }
            .navigationTitle("Прогрес")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Stats

    private var statsGrid: some View {
        let totalReminders = reminders.count
        let completedToday = reminders.filter(\.isCompletedToday).count
        let totalEntries = reminders.flatMap(\.entries).filter(\.isCompleted).count
        let longestStreak = reminders.map(\.bestStreak).max() ?? 0

        return LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            StatCard(title: "Активни", value: "\(totalReminders)", icon: "checkmark.circle", color: .blue)
            StatCard(title: "Днес", value: "\(completedToday)", icon: "checkmark.circle.fill", color: .green)
            StatCard(title: "Общо чек-ини", value: "\(totalEntries)", icon: "calendar.badge.checkmark", color: .purple)
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
                .foregroundStyle(.blue.gradient)
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Streaks

    private var streaksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Поредици (Streaks)")
                .font(.headline)

            ForEach(reminders.sorted(by: { $0.currentStreak > $1.currentStreak })) { reminder in
                HStack {
                    Image(systemName: reminder.icon)
                        .foregroundStyle(Color(hex: reminder.colorHex))
                    Text(reminder.name)
                    Spacer()
                    Label("\(reminder.currentStreak) дни", systemImage: "flame.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.orange)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

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

/// Stat card for the grid.
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ProgressOverviewView()
        .modelContainer(for: [Reminder.self, ReminderEntry.self], inMemory: true)
}
