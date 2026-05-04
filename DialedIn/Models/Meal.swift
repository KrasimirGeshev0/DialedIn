import Foundation
import SwiftData

@Model
final class Meal {
    var name: String
    var categoryRaw: String
    var calories: Int
    var note: String
    var createdAt: Date

    @Attribute(.externalStorage)
    var photoData: Data?

    var category: MealCategory {
        get { MealCategory(rawValue: categoryRaw) ?? .snack }
        set { categoryRaw = newValue.rawValue }
    }

    var icon: String { category.defaultIcon }
    var colorHex: String { category.defaultColorHex }

    init(
        name: String,
        category: MealCategory = .lunch,
        calories: Int = 0,
        note: String = "",
        photoData: Data? = nil
    ) {
        self.name = name
        self.categoryRaw = category.rawValue
        self.calories = calories
        self.note = note
        self.createdAt = Date()
        self.photoData = photoData
    }
}
