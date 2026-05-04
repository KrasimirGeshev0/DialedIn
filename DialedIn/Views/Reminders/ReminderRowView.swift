import SwiftUI

struct ReminderRowView: View {

    let reminder: Reminder
    var onToggle: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: reminder.icon)
                .font(.title3)
                .foregroundStyle(Color(hex: reminder.colorHex))
                .frame(width: 40, height: 40)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(reminder.name)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                if reminder.currentStreak > 0 {
                    Label("\(reminder.currentStreak) дни поред", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            Spacer()

            if reminder.trackingType == .boolean {
                Button {
                    onToggle?()
                } label: {
                    Image(systemName: reminder.isCompletedToday ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(reminder.isCompletedToday ? AppTheme.completedColor : .gray.opacity(0.35))
                }
                .buttonStyle(.plain)
            } else {
                Image(systemName: reminder.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(reminder.isCompletedToday ? AppTheme.completedColor : .gray.opacity(0.35))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: AppTheme.cardShadow, radius: 6, y: 2)
    }
}
