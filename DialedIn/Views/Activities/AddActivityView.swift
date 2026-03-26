import SwiftUI

/// Form for creating a new activity type.
struct AddActivityView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var activityType: ActivityType = .workout
    @State private var selectedIcon: String = "dumbbell.fill"
    @State private var selectedColorHex: String = "#EF4444"
    @State private var durationMinutes: Int = 30

    private let iconOptions = [
        "dumbbell.fill", "figure.run", "book.fill", "brain.head.profile",
        "laptopcomputer", "fork.knife", "star.fill", "figure.yoga",
        "bicycle", "figure.walk", "music.note", "paintbrush.fill",
        "gamecontroller.fill", "hammer.fill", "wrench.and.screwdriver.fill",
        "heart.fill"
    ]

    private let colorOptions = [
        "#EF4444", "#F97316", "#F59E0B", "#22C55E",
        "#3B82F6", "#8B5CF6", "#EC4899", "#06B6D4",
        "#6366F1", "#14B8A6"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Тип активност") {
                    Picker("Тип", selection: $activityType) {
                        ForEach(ActivityType.allCases) { type in
                            Label(type.displayName, systemImage: type.defaultIcon)
                                .tag(type)
                        }
                    }
                    .onChange(of: activityType) { _, newType in
                        if name.isEmpty || ActivityType.allCases.map(\.displayName).contains(name) {
                            name = newType.displayName
                        }
                        selectedIcon = newType.defaultIcon
                        selectedColorHex = newType.defaultColorHex
                        durationMinutes = newType.defaultDurationSeconds / 60
                    }
                }

                Section("Име") {
                    TextField("Напр. Сутрешна тренировка", text: $name)
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

                Section("Времетраене по подразбиране") {
                    Stepper("\(durationMinutes) мин", value: $durationMinutes, in: 5...180, step: 5)
                }
            }
            .navigationTitle("Нова активност")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Запази") { saveActivity() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                name = activityType.displayName
            }
        }
    }

    private func saveActivity() {
        let activity = Activity(
            name: name.trimmingCharacters(in: .whitespaces),
            activityType: activityType,
            icon: selectedIcon,
            colorHex: selectedColorHex,
            defaultDurationSeconds: durationMinutes * 60
        )
        modelContext.insert(activity)
        dismiss()
    }
}

#Preview {
    AddActivityView()
        .modelContainer(for: [Activity.self, ActivitySession.self], inMemory: true)
}
