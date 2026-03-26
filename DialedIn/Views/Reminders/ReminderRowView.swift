import SwiftUI

/// A single row showing a reminder's status in a list.
struct ReminderRowView: View {

    let reminder: Reminder

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: reminder.icon)
                .font(.title2)
                .foregroundStyle(Color(hex: reminder.colorHex))
                .frame(width: 44, height: 44)
                .background(Color(hex: reminder.colorHex).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
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

            Image(systemName: reminder.isCompletedToday ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(reminder.isCompletedToday ? .green : .gray.opacity(0.4))
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Color from Hex String extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
