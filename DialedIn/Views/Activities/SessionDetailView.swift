import SwiftUI

/// Detail view for a single completed session.
struct SessionDetailView: View {

    let session: ActivitySession

    var body: some View {
        List {
            Section("Детайли") {
                row(label: "Начало", value: session.startedAt.formatted(.dateTime.hour().minute().day().month()))

                if let end = session.endedAt {
                    row(label: "Край", value: end.formatted(.dateTime.hour().minute().day().month()))
                }

                row(label: "Планирано", value: formatSeconds(session.plannedDurationSeconds))
                row(label: "Реално", value: session.durationFormatted)

                HStack {
                    Text("Статус")
                    Spacer()
                    Label(
                        session.isCompleted ? "Завършена" : "Прекратена",
                        systemImage: session.isCompleted ? "checkmark.circle.fill" : "xmark.circle.fill"
                    )
                    .foregroundStyle(session.isCompleted ? .green : .red)
                }
            }

            if !session.note.isEmpty {
                Section("Бележка") {
                    Text(session.note)
                }
            }
        }
        .navigationTitle("Сесия")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }

    private func formatSeconds(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

#Preview {
    NavigationStack {
        SessionDetailView(session: ActivitySession(plannedDurationSeconds: 1800))
    }
}
