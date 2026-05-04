import Foundation

enum AppError: LocalizedError {
    case saveFailed(String)
    case deleteFailed(String)
    case cameraNotAvailable
    case photoSaveFailed
    case notificationPermissionDenied
    case unknownError(String)

    var errorDescription: String? {
        switch self {
        case .saveFailed(let detail):
            return "Грешка при запис: \(detail)"
        case .deleteFailed(let detail):
            return "Грешка при изтриване: \(detail)"
        case .cameraNotAvailable:
            return "Камерата не е налична на това устройство"
        case .photoSaveFailed:
            return "Грешка при запазване на снимката"
        case .notificationPermissionDenied:
            return "Нямате разрешение за известия"
        case .unknownError(let detail):
            return "Неочаквана грешка: \(detail)"
        }
    }
}
