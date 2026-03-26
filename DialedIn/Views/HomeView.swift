import SwiftUI
import SwiftData

/// Home dashboard showing today's reminders and a progress ring.
struct HomeView: View {

    @Query(filter: #Predicate<Reminder> { $0.isActive }, sort: \Reminder.sortOrder)
    private var reminders: [Reminder]

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    todayHeader
                    overallProgressCard

                    if reminders.isEmpty {
                        emptyStateView
                    } else {
                        todayRemindersSection
                    }
                }
                .padding()
            }
            .navigationTitle("DialedIn")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Subviews

    private var todayHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date(), format: .dateTime.weekday(.wide))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(Date(), format: .dateTime.day().month(.wide))
                    .font(.title2.bold())
            }
            Spacer()
        }
    }

    private var overallProgressCard: some View {
        let completed = reminders.filter(\.isCompletedToday).count
        let total = reminders.count
        let percentage = total > 0 ? Double(completed) / Double(total) : 0.0

        return VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: percentage)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: percentage)

                VStack {
                    Text("\(Int(percentage * 100))%")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text("\(completed)/\(total) напомняния")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 140, height: 140)

            Text("Дневен прогрес")
                .font(.headline)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var todayRemindersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Днешни напомняния")
                .font(.headline)

            ForEach(reminders) { reminder in
                NavigationLink(destination: ReminderDetailView(reminder: reminder)) {
                    ReminderRowView(reminder: reminder)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("Нямате напомняния")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Добавете от таб \"Напомняния\"")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .padding(.top, 40)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Reminder.self, ReminderEntry.self], inMemory: true)
}
