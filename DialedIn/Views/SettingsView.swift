import SwiftUI

struct SettingsView: View {

    @AppStorage("userName") private var userName = ""
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("userWeight") private var userWeight = 70
    @AppStorage("fitnessGoal") private var fitnessGoal = "maintain"
    @AppStorage("activityLevel") private var activityLevel = "moderate"
    @AppStorage("dailyCalorieGoal") private var dailyCalorieGoal = 2000

    private let goals = ["lose", "maintain", "gain"]
    private let goalLabels = ["Отслабване", "Поддържане", "Качване"]
    private let activityLevels = ["sedentary", "moderate", "active"]
    private let activityLabels = ["Заседнал", "Умерен", "Активен"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Профил") {
                    TextField("Вашето име", text: $userName)
                        .textInputAutocapitalization(.words)
                }

                Section("Калорийна цел") {
                    HStack {
                        Text("Тегло")
                        Spacer()
                        Stepper("\(userWeight) кг", value: $userWeight, in: 30...250)
                    }

                    Picker("Цел", selection: $fitnessGoal) {
                        ForEach(Array(zip(goals, goalLabels)), id: \.0) { value, label in
                            Text(label).tag(value)
                        }
                    }

                    Picker("Активност", selection: $activityLevel) {
                        ForEach(Array(zip(activityLevels, activityLabels)), id: \.0) { value, label in
                            Text(label).tag(value)
                        }
                    }

                    HStack {
                        Text("Дневна цел")
                        Spacer()
                        Text("\(dailyCalorieGoal) kcal")
                            .foregroundStyle(.secondary)
                    }
                }
                .onChange(of: userWeight) { _, _ in recalculateGoal() }
                .onChange(of: fitnessGoal) { _, _ in recalculateGoal() }
                .onChange(of: activityLevel) { _, _ in recalculateGoal() }

                Section("Известия") {
                    Toggle("Включи напомняния", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, newValue in
                            if newValue {
                                NotificationService.shared.requestPermission()
                            }
                        }
                }

                Section("За приложението") {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Разработчик")
                        Spacer()
                        Text("DialedIn Team")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Настройки")
        }
    }

    private func recalculateGoal() {
        dailyCalorieGoal = CalorieCalculator.calculateGoal(
            weightKg: userWeight,
            goal: fitnessGoal,
            activity: activityLevel
        )
    }
}

#Preview {
    SettingsView()
}
