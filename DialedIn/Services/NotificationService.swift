import Foundation
import UserNotifications

final class NotificationService {

    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    func requestPermission(completion: @escaping (Result<Bool, AppError>) -> Void = { _ in }) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.unknownError(error.localizedDescription)))
                } else if !granted {
                    completion(.failure(.notificationPermissionDenied))
                } else {
                    completion(.success(true))
                }
            }
        }
    }

    func scheduleReminder(for reminder: Reminder, completion: @escaping (Result<Void, AppError>) -> Void = { _ in }) {
        let content = UNMutableNotificationContent()
        content.title = "DialedIn"
        content.body = "Напомняне: \(reminder.name)"
        content.sound = .default
        content.userInfo = ["reminderName": reminder.name]

        var dateComponents = DateComponents()
        dateComponents.hour = reminder.reminderHour
        dateComponents.minute = reminder.reminderMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let identifier = "reminder-\(reminder.name)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        center.add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.unknownError(error.localizedDescription)))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    func cancelReminder(for reminder: Reminder) {
        let identifier = "reminder-\(reminder.name)"
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
}
