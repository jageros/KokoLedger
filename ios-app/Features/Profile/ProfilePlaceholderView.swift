import SwiftUI

struct ProfilePlaceholderView: View {
    var body: some View {
        PlaceholderPageView(
            title: "我的 / 用户中心",
            systemImage: "person.crop.circle"
        )
    }
}

#Preview {
    ProfilePlaceholderView()
}
