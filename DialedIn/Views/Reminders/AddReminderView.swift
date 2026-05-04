import SwiftUI

/// Form for creating or editing a reminder.
struct AddReminderView: View {

    /// Pass an existing reminder to edit it. Leave nil to create new.
    var editingReminder: Reminder?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedIcon = "checkmark.circle"
    @State private var selectedColorHex = "#3B82F6"
    @State private var trackingType: TrackingType = .boolean
    @State private var targetValue = ""
    @State private var unit = ""
    @State private var reminderTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var errorMessage: String?

    private var isEditing: Bool { editingReminder != nil }

    private let iconOptions = [
        "checkmark.circle", "sun.max.fill", "moon.fill", "drop.fill",
        "fork.knife", "figure.run", "book.fill", "brain.head.profile",
        "heart.fill", "face.smiling", "pill.fill", "leaf.fill",
        "cup.and.saucer.fill", "bed.double.fill", "music.note",
        "pencil.and.outline", "dumbbell.fill", "eye.fill"
    ]

    private let colorOptions = [
        "#3B82F6", "#EF4444", "#22C55E", "#F97316",
        "#8B5CF6", "#EC4899", "#06B6D4", "#6366F1",
        "#F59E0B", "#14B8A6"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Име") {
                    TextField("Напр. Сутрешен навик", text: $name)
                        .textInputAutocapitalization(.sentences)
                }

                Section("Икона") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Image(systemName: icon)
                                .font(.title3)
                                .frame(width: 40, height: 40)
                                .background(
                                    selectedIcon == icon
                                        ? Color(hex: selectedColorHex).opacity(0.2)
                                        : Color.gray.opacity(0.1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(selectedIcon == icon ? Color(hex: selectedColorHex) : .clear, lineWidth: 2)
                                )
                                .onTapGesture { selectedIcon = icon }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Цвят") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(colorOptions, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .stroke(.primary, lineWidth: selectedColorHex == hex ? 3 : 0)
                                )
                                .onTapGesture { selectedColorHex = hex }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Проследяване") {
                    Picker("Тип", selection: $trackingType) {
                        ForEach(TrackingType.allCases) { type in
                            Text(type.displayName).tag(type)
                        }
                    }

                    if trackingType == .numeric {
                        TextField("Целева стойност", text: $targetValue)
                            .keyboardType(.decimalPad)
                        TextField("Мерна единица (напр. чаши, минути)", text: $unit)
                    }
                }

                Section("Ежедневно напомняне") {
                    DatePicker("Час на напомняне", selection: $reminderTime, displayedComponents: .hourAndMinute)
                }
            }
            .navigationTitle(isEditing ? "Редактиране" : "Нов навик")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Запази") { saveReminder() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { loadExistingData() }
            .alert("Грешка", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func loadExistingData() {
        guard let r = editingReminder else { return }
        name = r.name
        selectedIcon = r.icon
        selectedColorHex = r.colorHex
        trackingType = r.trackingType
        targetValue = r.targetValue > 1 ? String(r.targetValue) : ""
        unit = r.unit
        reminderTime = Calendar.current.date(bySettingHour: r.reminderHour, minute: r.reminderMinute, second: 0, of: Date()) ?? Date()
    }

    private func saveReminder() {
        let calendar = Calendar.current
        let target = Double(targetValue) ?? 1.0

        if let r = editingReminder {
            NotificationService.shared.cancelReminder(for: r)
            r.name = name.trimmingCharacters(in: .whitespaces)
            r.icon = selectedIcon
            r.colorHex = selectedColorHex
            r.trackingType = trackingType
            r.targetValue = trackingType == .boolean ? 1.0 : target
            r.unit = unit
            r.reminderHour = calendar.component(.hour, from: reminderTime)
            r.reminderMinute = calendar.component(.minute, from: reminderTime)
            NotificationService.shared.scheduleReminder(for: r)
        } else {
            let reminder = Reminder(
                name: name.trimmingCharacters(in: .whitespaces),
                icon: selectedIcon,
                colorHex: selectedColorHex,
                trackingType: trackingType,
                targetValue: trackingType == .boolean ? 1.0 : target,
                unit: unit,
                reminderHour: calendar.component(.hour, from: reminderTime),
                reminderMinute: calendar.component(.minute, from: reminderTime)
            )
            modelContext.insert(reminder)
            NotificationService.shared.scheduleReminder(for: reminder)
        }

        do {
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = AppError.saveFailed(error.localizedDescription).localizedDescription
        }
    }
}

#Preview {
    AddReminderView()
        .modelContainer(for: [Reminder.self, ReminderEntry.self], inMemory: true)
}
