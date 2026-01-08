import SwiftUI

struct Theme {
    static let primary = Color(hex: "4CAF50") // Vibrant Golf Green
    static let primaryLight = Color(hex: "C8E6C9")
    static let secondary = Color(hex: "2E7D32") // Deep Moss Green
    static let accent = Color(hex: "FFC107") // Gold for ratings
    static let background = Color(hex: "F8F9FA")
    static let deepBlack = Color(hex: "121212")
    static let pureWhite = Color(hex: "FFFFFF")
    
    struct Shadows {
        static let soft = ShadowConfig(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
        static let medium = ShadowConfig(color: .black.opacity(0.12), radius: 20, x: 0, y: 10)
    }
}

struct ShadowConfig {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct GlassModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func glassmorphic() -> some View {
        self.modifier(GlassModifier())
    }
}
