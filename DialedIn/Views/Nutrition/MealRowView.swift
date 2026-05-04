import SwiftUI

struct MealRowView: View {

    let meal: Meal

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: meal.icon)
                .font(.title2)
                .foregroundStyle(Color(hex: meal.colorHex))
                .frame(width: 44, height: 44)
                .background(Color(hex: meal.colorHex).opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)
                Text(meal.category.displayName + " • " + meal.createdAt.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(meal.calories) kcal")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                if meal.photoData != nil {
                    Image(systemName: "camera.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: AppTheme.cardShadow, radius: 6, y: 2)
    }
}
