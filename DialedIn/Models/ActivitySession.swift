import Foundation
import SwiftData

/// A single timed session of an Activity.
/// Created when user taps "Start", ended when timer finishes or user stops it.
@Model
final class ActivitySession {

    var startedAt: Date
    var endedAt: Date?
    var plannedDurationSeconds: Int
    var actualDurationSeconds: Int?
    var note: String
    var isCompleted: Bool

    /// Extensibility field for v2+.
    /// Will hold JSON-encoded type-specific data:
    /// - Workout: exercises, sets, reps, weight
    /// - Meal: calories, macros
    /// - Run: distance, pace
    /// In v1 this is always nil.
    var metadataJSON: String?

    var activity: Activity?

    // MARK: - Computed

    var isRunning: Bool {
        endedAt == nil
    }

    var durationFormatted: String {
        let seconds = actualDurationSeconds ?? plannedDurationSeconds
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }

    // MARK: - Init

    init(
        plannedDurationSeconds: Int,
        note: String = ""
    ) {
        self.startedAt = Date()
        self.endedAt = nil
        self.plannedDurationSeconds = plannedDurationSeconds
        self.actualDurationSeconds = nil
        self.note = note
        self.isCompleted = false
        self.metadataJSON = nil
    }

    /// Call when the session ends (timer done or user stops it).
    func finish(completed: Bool = true) {
        self.endedAt = Date()
        self.actualDurationSeconds = Int(Date().timeIntervalSince(startedAt))
        self.isCompleted = completed
    }
}
