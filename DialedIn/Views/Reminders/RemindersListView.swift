import SwiftUI
import SwiftData

struct RemindersListView: View {

    @Query(sort: \Reminder.sortOrder) private var reminders: [Reminder]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddReminder = false
    @State private var errorMessage: String?
    @State private var router = DeepLinkRouter.shared
    @State private var navigatedReminder: Reminder?
    @State private var showDetail = false

    var body: some View {
        NavigationStack {
            Group {
                if reminders.isEmpty {
                    ContentUnavailableView(
                        "Няма навици",
                        systemImage: "checkmark.circle",
                        description: Text("Добавете първия си ежедневен навик с бутона +")
                    )
                } else {
                    List {
                        ForEach(reminders) { reminder in
                            NavigationLink(destination: ReminderDetailView(reminder: reminder)) {
                                ReminderRowView(reminder: reminder) {
                                    toggleCompletion(for: reminder)
                                }
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteReminder(reminder)
                                } label: {
                                    Label("Изтрий", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                if reminder.trackingType == .boolean {
                                    Button {
                                        toggleCompletion(for: reminder)
                                    } label: {
                                        Label(
                                            reminder.isCompletedToday ? "Отмени" : "Готово",
                                            systemImage: reminder.isCompletedToday ? "arrow.uturn.backward" : "checkmark"
                                        )
                                    }
                                    .tint(reminder.isCompletedToday ? .orange : AppTheme.completedColor)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Навици")
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
            .alert("Грешка", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
            .navigationDestination(isPresented: $showDetail) {
                if let reminder = navigatedReminder {
                    ReminderDetailView(reminder: reminder)
                }
            }
            .onAppear {
                handlePendingDeepLink()
            }
            .onChange(of: router.pendingReminderName) { _, _ in
                handlePendingDeepLink()
            }
        }
    }

    // MARK: - Actions

    private func handlePendingDeepLink() {
        guard let name = router.pendingReminderName else { return }
        if let reminder = reminders.first(where: { $0.name == name }) {
            navigatedReminder = reminder
            showDetail = true
        }
        router.pendingReminderName = nil
    }

    private func toggleCompletion(for reminder: Reminder) {
        guard reminder.trackingType == .boolean else { return }

        let today = Calendar.current.startOfDay(for: Date())
        if let entry = reminder.entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            entry.isCompleted.toggle()
            entry.value = entry.isCompleted ? 1.0 : 0.0
            entry.updatedAt = Date()
        } else {
            let entry = ReminderEntry(value: 1.0, isCompleted: true, note: "")
            entry.reminder = reminder
            modelContext.insert(entry)
        }

        reminder.recalculateStreak()

        do {
            try modelContext.save()
        } catch {
            errorMessage = AppError.saveFailed(error.localizedDescription).localizedDescription
        }
    }

    private func deleteReminder(_ reminder: Reminder) {
        NotificationService.shared.cancelReminder(for: reminder)
        modelContext.delete(reminder)
        do {
            try modelContext.save()
        } catch {
            errorMessage = AppError.deleteFailed(error.localizedDescription).localizedDescription
        }
    }
}

#Preview {
    RemindersListView()
        .modelContainer(for: [Reminder.self, ReminderEntry.self], inMemory: true)
}
