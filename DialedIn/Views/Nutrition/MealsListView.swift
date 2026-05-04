import SwiftUI
import SwiftData

struct MealsListView: View {

    @Query(sort: \Meal.createdAt, order: .reverse)
    private var allMeals: [Meal]

    @Environment(\.modelContext) private var modelContext
    @AppStorage("dailyCalorieGoal") private var dailyCalorieGoal = 2000

    @State private var showAddMeal = false
    @State private var errorMessage: String?

    private var todayMeals: [Meal] {
        allMeals.filter { Calendar.current.isDateInToday($0.createdAt) }
    }

    private var todayCalories: Int {
        todayMeals.reduce(0) { $0 + $1.calories }
    }

    var body: some View {
        NavigationStack {
            Group {
                if allMeals.isEmpty {
                    ContentUnavailableView(
                        "Няма записани хранения",
                        systemImage: "fork.knife",
                        description: Text("Добавете първото си хранене с бутона +")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            todayCaloriesCard
                            mealsSection
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Хранене")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddMeal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddMeal) {
                AddMealView()
            }
            .alert("Грешка", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    private var todayCaloriesCard: some View {
        VStack(spacing: 8) {
            Text("\(todayCalories)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
            Text("/ \(dailyCalorieGoal) kcal")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ProgressView(value: min(Double(todayCalories) / Double(max(dailyCalorieGoal, 1)), 1.0))
                .tint(todayCalories > dailyCalorieGoal ? .red : AppTheme.accent)
                .padding(.horizontal, 32)

            Text("\(todayMeals.count) хранения записани")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: AppTheme.cardRadius))
        .shadow(color: AppTheme.cardShadow, radius: AppTheme.cardShadowRadius, y: 2)
    }

    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(allMeals) { meal in
                NavigationLink(destination: MealDetailView(meal: meal)) {
                    MealRowView(meal: meal)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button("Изтрий", role: .destructive) {
                        deleteMeal(meal)
                    }
                }
            }
        }
    }

    private func deleteMeal(_ meal: Meal) {
        modelContext.delete(meal)
        do {
            try modelContext.save()
        } catch {
            errorMessage = AppError.deleteFailed(error.localizedDescription).localizedDescription
        }
    }
}

#Preview {
    MealsListView()
        .modelContainer(for: Meal.self, inMemory: true)
}
