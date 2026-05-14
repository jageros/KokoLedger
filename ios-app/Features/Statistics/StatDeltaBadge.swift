import SwiftUI

struct StatDeltaBadge: View {
    let delta: PercentageDelta

    var body: some View {
        Text(PercentFormatter.formatDelta(delta))
            .font(.caption2.weight(.semibold))
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, AppTheme.Spacing.small)
            .padding(.vertical, AppTheme.Spacing.xSmall)
            .background(backgroundColor)
            .clipShape(Capsule())
    }

    private var foregroundColor: Color {
        switch delta {
        case .increased:
            .green
        case .decreased:
            .red
        case .zero, .unchanged:
            .secondary
        case .unavailable:
            .secondary
        }
    }

    private var backgroundColor: Color {
        switch delta {
        case .increased:
            .green.opacity(0.12)
        case .decreased:
            .red.opacity(0.12)
        case .zero, .unchanged, .unavailable:
            Color(uiColor: .tertiarySystemFill)
        }
    }
}
