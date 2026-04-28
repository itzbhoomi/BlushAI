//
//  Theme.swift
//  Blush
//
//  Created by Bhoomi on 27/04/26.
//

//
// Theme.swift
// Blush
//

import SwiftUI

enum Theme {
    // MARK: - Background
    static let bgTop = Color(hex: "#FFF6F9")     // lighter, cleaner
    static let bgBottom = Color(hex: "#DFA3C4")  // less muddy, more airy

    // MARK: - Text (FIXED CONTRAST)
    static let textPrimary = Color(hex: "#2E1F27")   // much stronger
    static let textSecondary = Color(hex: "#5A3E4A")
    static let textMuted = Color(hex: "#8C6A77")

    // MARK: - Accent (STRONGER CTA)
    static let accentPink = Color(hex: "#E75480")    // punchy, premium pink
    static let accentPinkSoft = Color(hex: "#F7A1B5")

    static let successSoft = Color(hex: "#EBC3CF")

    // MARK: - Gradients
    static let backgroundGradient = LinearGradient(
        colors: [bgTop, bgBottom],
        startPoint: .top,
        endPoint: .bottom
    )

    static let accentGradient = LinearGradient(
        colors: [
            Color(hex: "#FF6F9F"),   // brighter top
            Color(hex: "#D94C8A")    // deeper bottom
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Cards (LESS GLASS, MORE STRUCTURE)
    static let cardBackground = Color.white.opacity(0.85)

    static let cardGradient = LinearGradient(
        colors: [
            Color.white.opacity(0.9),
            Color(hex: "#FFF6F9").opacity(0.7)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Glass (SIMPLIFIED)
    static let glassOverlay1 = Color.white.opacity(0.25)
    static let glassOverlay2 = Color.white.opacity(0.50)
    static let glassBorder = Color.white.opacity(0.5)

    static let primary = accentPink
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
            (a, r, g, b) = (255, 255, 255, 255)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

extension Font {
    static func appFont(size: CGFloat = 17) -> Font {
        .custom("Sniglet-Regular", size: size)
    }
}
