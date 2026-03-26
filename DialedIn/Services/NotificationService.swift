import Foundation
import UserNotifications

/// Service responsible for scheduling and managing local push notifications.
/// Singleton pattern -- accessed as NotificationService.shared.
final class NotificationService {

    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    /// Ask the user for permission to show notifications.
    func requestPermission() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
            print("Notifications permission granted: \(granted)")
        }
    }

    /// Schedule a daily reminder notification.
    func scheduleReminder(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = "DialedIn"
        content.body = "Време е за: \(reminder.name)"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = reminder.reminderHour
        dateComponents.minute = reminder.reminderMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let identifier = "reminder-\(reminder.name)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    /// Cancel the notification for a specific reminder.
    func cancelReminder(for reminder: Reminder) {
        let identifier = "reminder-\(reminder.name)"
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    /// Cancel all scheduled notifications.
    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
}
