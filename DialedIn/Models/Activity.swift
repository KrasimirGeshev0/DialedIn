import Foundation
import SwiftData

/// An Activity is a type of timed session the user can start.
/// Examples: "Workout", "Study", "Run", "Meditation"
///
/// The user defines activity types, then starts timed sessions from them.
/// A countdown timer appears on the lock screen / Dynamic Island.
@Model
final class Activity {

    var name: String
    var activityTypeRaw: String  // maps to ActivityType enum
    var icon: String             // SF Symbol name
    var colorHex: String
    var defaultDurationSeconds: Int  // e.g. 2700 for 45 min
    var createdAt: Date
    var isActive: Bool
    var sortOrder: Int

    @Relationship(deleteRule: .cascade)
    var sessions: [ActivitySession] = []

    // MARK: - Computed

    var activityType: ActivityType {
        get { ActivityType(rawValue: activityTypeRaw) ?? .custom }
        set { activityTypeRaw = newValue.rawValue }
    }

    var totalSessions: Int {
        sessions.filter(\.isCompleted).count
    }

    var totalDurationFormatted: String {
        let totalSeconds = sessions
            .compactMap(\.actualDurationSeconds)
            .reduce(0, +)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        if hours > 0 {
            return "\(hours)ч \(minutes)мин"
        }
        return "\(minutes)мин"
    }

    // MARK: - Init

    init(
        name: String,
        activityType: ActivityType = .custom,
        icon: String? = nil,
        colorHex: String? = nil,
        defaultDurationSeconds: Int = 1800,
        sortOrder: Int = 0
    ) {
        self.name = name
        self.activityTypeRaw = activityType.rawValue
        self.icon = icon ?? activityType.defaultIcon
        self.colorHex = colorHex ?? activityType.defaultColorHex
        self.defaultDurationSeconds = defaultDurationSeconds
        self.createdAt = Date()
        self.isActive = true
        self.sortOrder = sortOrder
    }
}
