import ActivityKit
import Foundation

/// Defines the data structure for the Live Activity timer on lock screen / Dynamic Island.
/// This file must be added to BOTH the main app target and the widget extension target.
struct TimerActivityAttributes: ActivityAttributes {

    // Static data -- set once when activity starts
    let activityName: String
    let iconName: String
    let colorHex: String

    // Dynamic data -- can be updated while the Live Activity is running
    struct ContentState: Codable, Hashable {
        let endTime: Date
        let isPaused: Bool
        let elapsedAtPause: Int     // seconds elapsed when paused
        let totalDuration: Int      // total planned seconds
    }
}
