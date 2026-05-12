import SwiftUI

enum AppTheme {
    enum Spacing {
        static let xSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
    }

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }

    enum Shadow {
        static let color = Color.black.opacity(0.08)
        static let radius: CGFloat = 12
        static let x: CGFloat = 0
        static let y: CGFloat = 4
    }

    static let cardRadius = CornerRadius.large
}
