import Foundation
import SwiftData

/// Records a user's progress on a Reminder for a specific day.
/// One ReminderEntry per Reminder per day.
@Model
final class ReminderEntry {

    var date: Date
    var value: Double       // 1.0 for boolean done, or numeric value
    var isCompleted: Bool
    var note: String
    var updatedAt: Date

    var reminder: Reminder?

    init(date: Date = Date(), value: Double = 0.0, isCompleted: Bool = false, note: String = "") {
        self.date = Calendar.current.startOfDay(for: date)
        self.value = value
        self.isCompleted = isCompleted
        self.note = note
        self.updatedAt = Date()
    }
}
