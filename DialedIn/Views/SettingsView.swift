import SwiftUI

/// Settings screen for app-level configuration.
struct SettingsView: View {

    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("appLanguage") private var appLanguage = "bg"

    var body: some View {
        NavigationStack {
            Form {
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
}

#Preview {
    SettingsView()
}
