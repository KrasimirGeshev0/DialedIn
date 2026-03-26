import SwiftUI

/// Pre-session screen: pick duration and start the timer.
struct StartSessionView: View {

    let activity: Activity

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var durationMinutes: Int = 30

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Image(systemName: activity.icon)
                    .font(.system(size: 64))
                    .foregroundStyle(Color(hex: activity.colorHex))

                Text(activity.name)
                    .font(.title2.weight(.semibold))

                // Duration picker
                VStack(spacing: 12) {
                    Text("Времетраене")
                        .font(.headline)

                    HStack(spacing: 20) {
                        ForEach([15, 30, 45, 60], id: \.self) { mins in
                            Button {
                                durationMinutes = mins
                            } label: {
                                Text("\(mins)")
                                    .font(.body.weight(.medium))
                                    .frame(width: 52, height: 52)
                                    .background(
                                        durationMinutes == mins
                                            ? Color(hex: activity.colorHex)
                                            : Color.gray.opacity(0.15)
                                    )
                                    .foregroundStyle(durationMinutes == mins ? .white : .primary)
                                    .clipShape(Circle())
                            }
                        }
                    }

                    Stepper("\(durationMinutes) мин", value: $durationMinutes, in: 1...180, step: 5)
                        .padding(.horizontal)
                }

                Spacer()

                Button {
                    startSession()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Старт")
                    }
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: activity.colorHex), in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)
            }
            .padding(.top, 40)
            .padding()
            .navigationTitle("Нова сесия")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                }
            }
            .onAppear {
                durationMinutes = activity.defaultDurationSeconds / 60
            }
        }
    }

    private func startSession() {
        // Save session to database
        let session = ActivitySession(plannedDurationSeconds: durationMinutes * 60)
        session.activity = activity
        modelContext.insert(session)

        // Start the timer (in-app bar + Live Activity on lock screen)
        LiveActivityService.shared.startSession(
            name: activity.name,
            icon: activity.icon,
            colorHex: activity.colorHex,
            durationSeconds: durationMinutes * 60
        )

        dismiss()
    }
}

#Preview {
    StartSessionView(activity: Activity(name: "Тренировка", activityType: .workout))
        .modelContainer(for: [Activity.self, ActivitySession.self], inMemory: true)
}
