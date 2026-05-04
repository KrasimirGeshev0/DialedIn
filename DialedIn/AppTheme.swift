import SwiftUI

enum AppTheme {
    static let accent = Color(hex: "#4B5563")
    static let accentLight = Color(hex: "#4B5563").opacity(0.10)
    static let completedColor = Color(hex: "#22C55E")
    static let cardRadius: CGFloat = 16
    static let cardShadow: Color = .black.opacity(0.04)
    static let cardShadowRadius: CGFloat = 8
}

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
