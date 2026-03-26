import ActivityKit
import WidgetKit
import SwiftUI

struct DialedInTimerLiveActivity: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock screen banner -- keep it simple
            HStack {
                Image(systemName: context.attributes.iconName)
                    .font(.title2)

                Text(context.attributes.activityName)
                    .font(.headline)

                Spacer()

                if context.state.isPaused {
                    Text("Пауза")
                        .font(.headline)
                        .foregroundStyle(.orange)
                } else {
                    Text(timerInterval: Date.now...context.state.endTime, countsDown: true)
                        .font(.title2.monospacedDigit().weight(.bold))
                        .multilineTextAlignment(.trailing)
                }
            }
            .padding()

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.attributes.iconName)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(timerInterval: Date.now...context.state.endTime, countsDown: true)
                        .monospacedDigit()
                }
            } compactLeading: {
                Image(systemName: context.attributes.iconName)
            } compactTrailing: {
                Text(timerInterval: Date.now...context.state.endTime, countsDown: true)
                    .monospacedDigit()
                    .frame(width: 50)
            } minimal: {
                Image(systemName: context.attributes.iconName)
            }
        }
    }
}
