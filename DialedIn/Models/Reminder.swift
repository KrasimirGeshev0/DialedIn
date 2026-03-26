import Foundation
import SwiftData

/// A Reminder is a daily habit the user wants to track.
/// Examples: "Morning routine", "Drink 8 glasses of water", "Skincare", "Read 30 min"
///
/// Users create their own reminders with custom name, icon, and color.
/// Each day they check them off (boolean) or log a numeric value.
@Model
final class Reminder {

    var name: String
    var icon: String            // SF Symbol name, e.g. "drop.fill"
    var colorHex: String        // e.g. "#3B82F6"

    var trackingTypeRaw: String // "boolean" or "numeric"
    var targetValue: Double     // 1.0 for boolean, e.g. 8.0 for "8 glasses"
    var unit: String            // "", "чаши", "минути", "km"

    var currentStreak: Int
    var bestStreak: Int
    var createdAt: Date
    var isActive: Bool

    var reminderHour: Int
    var reminderMinute: Int
    var sortOrder: Int

    @Relationship(deleteRule: .cascade)
    var entries: [ReminderEntry] = []

    // MARK: - Computed Properties

    var trackingType: TrackingType {
        get { TrackingType(rawValue: trackingTypeRaw) ?? .boolean }
        set { trackingTypeRaw = newValue.rawValue }
    }

    var isCompletedToday: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return entries.contains { Calendar.current.isDate($0.date, inSameDayAs: today) && $0.isCompleted }
    }

    var todayProgress: Double {
        let today = Calendar.current.startOfDay(for: Date())
        guard let todayEntry = entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) else {
            return 0.0
        }
        if trackingType == .boolean {
            return todayEntry.isCompleted ? 1.0 : 0.0
        }
        guard targetValue > 0 else { return 0.0 }
        return min(todayEntry.value / targetValue, 1.0)
    }

    // MARK: - Init

    init(
        name: String,
        icon: String = "checkmark.circle",
        colorHex: String = "#3B82F6",
        trackingType: TrackingType = .boolean,
        targetValue: Double = 1.0,
        unit: String = "",
        reminderHour: Int = 9,
        reminderMinute: Int = 0,
        sortOrder: Int = 0
    ) {
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.trackingTypeRaw = trackingType.rawValue
        self.targetValue = targetValue
        self.unit = unit
        self.currentStreak = 0
        self.bestStreak = 0
        self.createdAt = Date()
        self.isActive = true
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
        self.sortOrder = sortOrder
    }
}

// MARK: - TrackingType Enum

enum TrackingType: String, Codable, CaseIterable, Identifiable {
    case boolean = "boolean"
    case numeric = "numeric"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .boolean: return "Да/Не"
        case .numeric: return "Числова стойност"
        }
    }
}
