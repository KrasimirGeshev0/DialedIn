import Foundation

enum MealCategory: String, Codable, CaseIterable, Identifiable {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"
    case snack = "snack"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .breakfast: return "Закуска"
        case .lunch: return "Обяд"
        case .dinner: return "Вечеря"
        case .snack: return "Снакс"
        }
    }

    var defaultIcon: String {
        switch self {
        case .breakfast: return "sun.horizon.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "leaf.fill"
        }
    }

    var defaultColorHex: String {
        switch self {
        case .breakfast: return "#F97316"
        case .lunch: return "#22C55E"
        case .dinner: return "#3B82F6"
        case .snack: return "#8B5CF6"
        }
    }
}
