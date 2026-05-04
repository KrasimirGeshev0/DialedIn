import ActivityKit
import Foundation
import SwiftUI

/// Service managing the active timer session.
/// Shows as a floating bar in-app, and as a Live Activity on lock screen.
@Observable
final class LiveActivityService {

    static let shared = LiveActivityService()

    // Timer state
    private(set) var isRunning = false
    private(set) var isPaused = false
    private(set) var endTime: Date?
    private(set) var remainingAtPause: Int = 0
    private(set) var totalDuration: Int = 0

    // Session info for display
    private(set) var activityName: String = ""
    private(set) var activityIcon: String = ""
    private(set) var activityColorHex: String = "#3B82F6"

    // Live Activity (may fail on simulator -- that's OK)
    private var currentLiveActivity: ActivityKit.Activity<TimerActivityAttributes>?

    // Error reporting
    var lastError: AppError?

    // Expanded timer view toggle
    var showExpandedTimer = false

    private init() {}

    /// Start a timer session.
    func startSession(
        name: String,
        icon: String,
        colorHex: String,
        durationSeconds: Int
    ) {
        let end = Date.now.addingTimeInterval(TimeInterval(durationSeconds))

        // Store display info
        activityName = name
        activityIcon = icon
        activityColorHex = colorHex
        totalDuration = durationSeconds
        endTime = end
        isRunning = true
        isPaused = false

        // Try to start Live Activity (will fail on simulator without Dynamic Island -- that's fine)
        startLiveActivity(name: name, icon: icon, colorHex: colorHex, endTime: end, durationSeconds: durationSeconds)
    }

    /// Pause the running timer.
    func pauseSession() {
        guard let end = endTime else { return }
        let remaining = max(0, Int(end.timeIntervalSinceNow))
        remainingAtPause = remaining
        isPaused = true

        updateLiveActivity(endTime: end, isPaused: true, elapsedAtPause: totalDuration - remaining)
    }

    /// Resume from pause.
    func resumeSession() {
        let newEnd = Date.now.addingTimeInterval(TimeInterval(remainingAtPause))
        endTime = newEnd
        isPaused = false

        updateLiveActivity(endTime: newEnd, isPaused: false, elapsedAtPause: 0)
    }

    /// End the session and dismiss everything.
    func endSession() {
        isRunning = false
        isPaused = false
        endTime = nil
        showExpandedTimer = false

        endLiveActivity()
    }

    // MARK: - Live Activity (lock screen / Dynamic Island)

    private func startLiveActivity(name: String, icon: String, colorHex: String, endTime: Date, durationSeconds: Int) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are DISABLED on this device. Enable in Settings > DialedIn > Live Activities")
            return
        }
        print("Live Activities are enabled, starting...")

        let attributes = TimerActivityAttributes(
            activityName: name,
            iconName: icon,
            colorHex: colorHex
        )
        let state = TimerActivityAttributes.ContentState(
            endTime: endTime,
            isPaused: false,
            elapsedAtPause: 0,
            totalDuration: durationSeconds
        )

        do {
            currentLiveActivity = try ActivityKit.Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
            print("Live Activity started successfully! ID: \(currentLiveActivity?.id ?? "unknown")")
        } catch {
            lastError = .unknownError(error.localizedDescription)
        }
    }

    private func updateLiveActivity(endTime: Date, isPaused: Bool, elapsedAtPause: Int) {
        guard let activity = currentLiveActivity else { return }
        let state = TimerActivityAttributes.ContentState(
            endTime: endTime,
            isPaused: isPaused,
            elapsedAtPause: elapsedAtPause,
            totalDuration: totalDuration
        )
        Task { await activity.update(.init(state: state, staleDate: nil)) }
    }

    private func endLiveActivity() {
        guard let activity = currentLiveActivity else { return }
        let state = TimerActivityAttributes.ContentState(
            endTime: Date.now,
            isPaused: false,
            elapsedAtPause: 0,
            totalDuration: totalDuration
        )
        Task { await activity.end(.init(state: state, staleDate: nil), dismissalPolicy: .immediate) }
        currentLiveActivity = nil
    }
}
