import SwiftUI
import SwiftData
import ActivityKit

@main
struct DialedInApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Reminder.self, ReminderEntry.self,
            Activity.self, ActivitySession.self,
            Meal.self
        ])
    }
}
