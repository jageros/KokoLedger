import SwiftUI

struct AppButton: View {
    enum Style {
        case primary
        case secondary
        case destructive
    }

    let title: String
    let systemImage: String?
    let style: Style
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    init(
        _ title: String,
        systemImage: String? = nil,
        style: Style = .primary,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.small) {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(foregroundColor)
                } else if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 46)
        }
        .buttonStyle(.plain)
        .foregroundStyle(foregroundColor)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium, style: .continuous)
                .stroke(borderColor, lineWidth: style == .secondary ? 1 : 0)
        )
        .opacity(isDisabled || isLoading ? 0.55 : 1)
        .disabled(isDisabled || isLoading)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:
            Color.accentColor
        case .secondary:
            Color(uiColor: .secondarySystemGroupedBackground)
        case .destructive:
            Color.red
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive:
            .white
        case .secondary:
            .primary
        }
    }

    private var borderColor: Color {
        Color(uiColor: .separator)
    }
}
