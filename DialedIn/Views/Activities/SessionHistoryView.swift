import SwiftUI
import SwiftData

/// Shows past sessions for a specific activity type.
struct SessionHistoryView: View {

    let activity: Activity

    private var completedSessions: [ActivitySession] {
        activity.sessions
            .filter { $0.endedAt != nil }
            .sorted { $0.startedAt > $1.startedAt }
    }

    var body: some View {
        List {
            if completedSessions.isEmpty {
                ContentUnavailableView(
                    "Няма сесии",
                    systemImage: "clock",
                    description: Text("Стартирайте първата си сесия")
                )
            } else {
                ForEach(completedSessions) { session in
                    NavigationLink(destination: SessionDetailView(session: session)) {
                        sessionRow(session)
                    }
                }
            }
        }
        .navigationTitle("История")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sessionRow(_ session: ActivitySession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.startedAt, format: .dateTime.day().month().year())
                    .font(.body.weight(.medium))
                Text(session.startedAt, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(session.durationFormatted)
                    .font(.body.monospacedDigit().weight(.medium))
                HStack(spacing: 4) {
                    Image(systemName: session.isCompleted ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(session.isCompleted ? .green : .red)
                    Text(session.isCompleted ? "Завършена" : "Прекратена")
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        SessionHistoryView(activity: Activity(name: "Тренировка", activityType: .workout))
    }
    .modelContainer(for: [Activity.self, ActivitySession.self], inMemory: true)
}
