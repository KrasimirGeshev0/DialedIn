import SwiftUI
import SwiftData

/// List of all reminders with add/delete functionality.
struct RemindersListView: View {

    @Query(sort: \Reminder.sortOrder) private var reminders: [Reminder]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddReminder = false

    var body: some View {
        NavigationStack {
            Group {
                if reminders.isEmpty {
                    ContentUnavailableView(
                        "Няма напомняния",
                        systemImage: "checkmark.circle",
                        description: Text("Добавете първото си ежедневно напомняне")
                    )
                } else {
                    List {
                        ForEach(reminders) { reminder in
                            NavigationLink(destination: ReminderDetailView(reminder: reminder)) {
                                ReminderRowView(reminder: reminder)
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                        .onDelete(perform: deleteReminders)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Напомняния")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddReminder = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                AddReminderView()
            }
        }
    }

    private func deleteReminders(at offsets: IndexSet) {
        for index in offsets {
            let reminder = reminders[index]
            NotificationService.shared.cancelReminder(for: reminder)
            modelContext.delete(reminder)
        }
    }
}

#Preview {
    RemindersListView()
        .modelContainer(for: [Reminder.self, ReminderEntry.self], inMemory: true)
}
