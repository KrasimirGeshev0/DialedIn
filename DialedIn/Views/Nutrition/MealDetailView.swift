import SwiftUI

struct MealDetailView: View {

    @Bindable var meal: Meal
    @State private var showEditSheet = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let data = meal.photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxHeight: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: meal.icon)
                            .font(.title2)
                            .foregroundStyle(Color(hex: meal.colorHex))
                            .frame(width: 44, height: 44)
                            .background(Color(hex: meal.colorHex).opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(meal.name)
                                .font(.title3.weight(.semibold))
                            Text(meal.category.displayName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("\(meal.calories) kcal")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color(hex: meal.colorHex))
                    }

                    if !meal.note.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Бележка")
                                .font(.headline)
                            Text(meal.note)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }

                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.secondary)
                        Text(meal.createdAt.formatted(date: .long, time: .shortened))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
            .padding()
        }
        .navigationTitle("Детайли")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showEditSheet = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            AddMealView(editingMeal: meal)
        }
        .background(Color(.systemGroupedBackground))
    }
}
