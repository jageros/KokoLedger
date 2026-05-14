import SwiftUI

struct MainTabView: View {
    @ObservedObject var session: AppSession
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases) { tab in
                NavigationStack {
                    tab.content(session: session)
                        .navigationTitle(tab.title)
                }
                .tabItem {
                    tab.label
                }
                .tag(tab)
            }
        }
    }
}

private enum AppTab: String, CaseIterable, Identifiable {
    case home
    case statistics
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home:
            "首页"
        case .statistics:
            "统计"
        case .profile:
            "我的"
        }
    }

    var systemImage: String {
        switch self {
        case .home:
            "house"
        case .statistics:
            "chart.pie"
        case .profile:
            "person.crop.circle"
        }
    }

    @ViewBuilder
    @MainActor
    func content(session: AppSession) -> some View {
        switch self {
        case .home:
            HomeView(session: session)
        case .statistics:
            StatisticsView(session: session)
        case .profile:
            ProfileView(session: session)
        }
    }

    var label: some View {
        Label(title, systemImage: systemImage)
    }
}

#Preview {
    MainTabView(session: AppSession())
}
