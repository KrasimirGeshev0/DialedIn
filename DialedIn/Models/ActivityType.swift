import Foundation

/// Predefined activity types with default icons and colors.
/// Users can also pick "custom" and set their own icon/color.
enum ActivityType: String, Codable, CaseIterable, Identifiable {
    case workout = "workout"
    case run = "run"
    case study = "study"
    case meditation = "meditation"
    case work = "work"
    case meal = "meal"
    case custom = "custom"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .workout: return "Тренировка"
        case .run: return "Бягане"
        case .study: return "Учене"
        case .meditation: return "Медитация"
        case .work: return "Работа"
        case .meal: return "Хранене"
        case .custom: return "Друго"
        }
    }

    var defaultIcon: String {
        switch self {
        case .workout: return "dumbbell.fill"
        case .run: return "figure.run"
        case .study: return "book.fill"
        case .meditation: return "brain.head.profile"
        case .work: return "laptopcomputer"
        case .meal: return "fork.knife"
        case .custom: return "star.fill"
        }
    }

    var defaultColorHex: String {
        switch self {
        case .workout: return "#EF4444"
        case .run: return "#F97316"
        case .study: return "#3B82F6"
        case .meditation: return "#8B5CF6"
        case .work: return "#6B7280"
        case .meal: return "#22C55E"
        case .custom: return "#F59E0B"
        }
    }

    static var trainingTypes: [ActivityType] {
        [.workout, .run, .meditation, .custom]
    }

    var defaultDurationSeconds: Int {
        switch self {
        case .workout: return 3600      // 60 min
        case .run: return 1800          // 30 min
        case .study: return 2700        // 45 min
        case .meditation: return 600    // 10 min
        case .work: return 5400         // 90 min
        case .meal: return 1200         // 20 min
        case .custom: return 1800       // 30 min
        }
    }
}
