import SwiftUI

struct PlaceholderPageView: View {
    let title: String
    let systemImage: String

    var body: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: systemImage)
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(.tint)

            Text(title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppTheme.Spacing.large)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    PlaceholderPageView(title: "首页 / 记账", systemImage: "square.and.pencil")
}
