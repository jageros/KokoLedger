import SwiftUI

struct LoadingView: View {
    var message = "加载中"

    var body: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            ProgressView()
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
    }
}
