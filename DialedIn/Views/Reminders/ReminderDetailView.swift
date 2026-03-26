import SwiftUI
import SwiftData
import Charts

/// Detail view for a single reminder: check-in, streaks, 30-day chart.
struct ReminderDetailView: View {

    @Bindable var reminder: Reminder
    @Environment(\.modelContext) private var modelContext

    @State private var todayValue: String = ""
    @State private var todayNote: String = ""
    @State private var showingEdit = false

    private var recentEntries: [ReminderEntry] {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return reminder.entries
            .filter { $0.date >= thirtyDaysAgo }
            .sorted { $0.date < $1.date }
    }

    private var todayEntry: ReminderEntry? {
        let today = Calendar.current.startOfDay(for: Date())
        return reminder.entries.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                reminderHeader
                checkInCard
                streakCard
                if !recentEntries.isEmpty { chartCard }
            }
            .padding()
        }
        .navigationTitle(reminder.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingEdit = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            AddReminderView(editingReminder: reminder)
        }
        .onAppear {
            if let entry = todayEntry {
                todayValue = entry.value > 0 ? String(entry.value) : ""
                todayNote = entry.note
            }
        }
    }

    // MARK: - Header

    private var reminderHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: reminder.icon)
                .font(.system(size: 44))
                .foregroundStyle(Color(hex: reminder.colorHex))

            if reminder.trackingType == .numeric {
                Text("Цел: \(reminder.targetValue, specifier: "%.1f") \(reminder.unit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Check-In

    private var checkInCard: some View {
        VStack(spacing: 16) {
            Text("Днешен чек-ин")
                .font(.headline)

            if reminder.trackingType == .boolean {
                Button { toggleBoolean() } label: {
                    HStack {
                        Image(systemName: reminder.isCompletedToday ? "checkmark.circle.fill" : "circle")
                        Text(reminder.isCompletedToday ? "Изпълнено!" : "Маркирай като изпълнено")
                    }
                    .font(.body.weight(.medium))
                    .foregroundStyle(reminder.isCompletedToday ? .green : .primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        reminder.isCompletedToday ? Color.green.opacity(0.15) : Color.gray.opacity(0.1),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                }
            } else {
                HStack {
                    TextField("Стойност", text: $todayValue)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                    Text(reminder.unit)
                        .foregroundStyle(.secondary)
                    Button("Запиши") { saveNumericEntry() }
                        .buttonStyle(.borderedProminent)
                }
            }

            TextField("Бележка (незадължително)", text: $todayNote, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Streaks

    private var streakCard: some View {
        HStack(spacing: 24) {
            VStack(spacing: 4) {
                Text("\(reminder.currentStreak)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)
                Text("Текущ streak")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Divider().frame(height: 50)
            VStack(spacing: 4) {
                Text("\(reminder.bestStreak)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue)
                Text("Най-добър")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Divider().frame(height: 50)
            VStack(spacing: 4) {
                Text("\(reminder.entries.filter(\.isCompleted).count)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.green)
                Text("Общо дни")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Chart

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Последните 30 дни")
                .font(.headline)

            Chart(recentEntries) { entry in
                if reminder.trackingType == .boolean {
                    BarMark(
                        x: .value("Дата", entry.date, unit: .day),
                        y: .value("Статус", entry.isCompleted ? 1 : 0)
                    )
                    .foregroundStyle(entry.isCompleted ? .green : .gray.opacity(0.3))
                } else {
                    LineMark(
                        x: .value("Дата", entry.date, unit: .day),
                        y: .value("Стойност", entry.value)
                    )
                    .foregroundStyle(Color(hex: reminder.colorHex))
                    .interpolationMethod(.catmullRom)

                    RuleMark(y: .value("Цел", reminder.targetValue))
                        .foregroundStyle(.red.opacity(0.5))
                        .lineStyle(StrokeStyle(dash: [5, 5]))
                }
            }
            .frame(height: 200)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) {
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Actions

    private func toggleBoolean() {
        if let entry = todayEntry {
            entry.isCompleted.toggle()
            entry.value = entry.isCompleted ? 1.0 : 0.0
            entry.updatedAt = Date()
        } else {
            let entry = ReminderEntry(value: 1.0, isCompleted: true, note: todayNote)
            entry.reminder = reminder
            modelContext.insert(entry)
        }
        updateStreak()
    }

    private func saveNumericEntry() {
        let value = Double(todayValue) ?? 0.0
        let completed = value >= reminder.targetValue

        if let entry = todayEntry {
            entry.value = value
            entry.isCompleted = completed
            entry.note = todayNote
            entry.updatedAt = Date()
        } else {
            let entry = ReminderEntry(value: value, isCompleted: completed, note: todayNote)
            entry.reminder = reminder
            modelContext.insert(entry)
        }
        updateStreak()
    }

    private func updateStreak() {
        var streak = 0
        let calendar = Calendar.current
        var checkDate = calendar.startOfDay(for: Date())

        while true {
            let hasCompleted = reminder.entries.contains {
                calendar.isDate($0.date, inSameDayAs: checkDate) && $0.isCompleted
            }
            if hasCompleted {
                streak += 1
                guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = prev
            } else {
                break
            }
        }

        reminder.currentStreak = streak
        if streak > reminder.bestStreak {
            reminder.bestStreak = streak
        }
    }
}

#Preview {
    NavigationStack {
        ReminderDetailView(reminder: Reminder(
            name: "Пий вода",
            icon: "drop.fill",
            colorHex: "#06B6D4",
            trackingType: .numeric,
            targetValue: 8.0,
            unit: "чаши"
        ))
    }
    .modelContainer(for: [Reminder.self, ReminderEntry.self], inMemory: true)
}
