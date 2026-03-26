import SwiftUI

/// Form for creating a new reminder.
struct AddReminderView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedIcon = "checkmark.circle"
    @State private var selectedColorHex = "#3B82F6"
    @State private var trackingType: TrackingType = .boolean
    @State private var targetValue = ""
    @State private var unit = ""
    @State private var enableReminder = false
    @State private var reminderTime = Date()

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
                    TextField("Напр. Сутрешна рутина", text: $name)
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

                Section("Напомняне") {
                    Toggle("Ежедневно напомняне", isOn: $enableReminder)
                    if enableReminder {
                        DatePicker("Час", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
            }
            .navigationTitle("Ново напомняне")
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
        }
    }

    private func saveReminder() {
        let calendar = Calendar.current
        let target = Double(targetValue) ?? 1.0

        let reminder = Reminder(
            name: name.trimmingCharacters(in: .whitespaces),
            icon: selectedIcon,
            colorHex: selectedColorHex,
            trackingType: trackingType,
            targetValue: trackingType == .boolean ? 1.0 : target,
            unit: unit,
            reminderHour: enableReminder ? calendar.component(.hour, from: reminderTime) : nil,
            reminderMinute: enableReminder ? calendar.component(.minute, from: reminderTime) : nil
        )

        modelContext.insert(reminder)

        if enableReminder {
            NotificationService.shared.scheduleReminder(for: reminder)
        }

        dismiss()
    }
}

#Preview {
    AddReminderView()
        .modelContainer(for: [Reminder.self, ReminderEntry.self], inMemory: true)
}
