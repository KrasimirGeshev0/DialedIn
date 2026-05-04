import Foundation

@Observable
final class DeepLinkRouter {
    static let shared = DeepLinkRouter()
    var selectedTab: Int = 0
    var pendingReminderName: String?
    private init() {}
}
