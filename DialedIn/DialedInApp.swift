import SwiftUI
import SwiftData
import ActivityKit

/// Main entry point of the DialedIn app.
/// Think of this like `public static void main(String[] args)` in Java.
@main
struct DialedInApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Reminder.self, ReminderEntry.self,
            Activity.self, ActivitySession.self
        ])
    }
}
