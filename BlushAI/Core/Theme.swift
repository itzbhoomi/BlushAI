//
//  Theme.swift
//  Blush
//
//  Created by Bhoomi on 27/04/26.
//

import SwiftUI

enum Theme {
    static let bgTop = Color(hex: "#FFF8FA")
    static let bgBottom = Color(hex: "#FFF2F5")
    
    static let textPrimary = Color(hex: "#5C4550")
    static let textSecondary = Color(hex: "#8D7380")
    static let textMuted = Color(hex: "#B59AA6")
    
    static let accentPink = Color(hex: "#F39CB3")
    static let successSoft = Color(hex: "#E7B7C7")
    
    // Glass styling specific
    static let glassOverlay1 = Color(red: 255/255, green: 228/255, blue: 236/255).opacity(0.55)
    static let glassOverlay2 = Color(red: 255/255, green: 228/255, blue: 236/255).opacity(0.68)
    static let glassBorder = Color.white.opacity(0.40)
    
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
