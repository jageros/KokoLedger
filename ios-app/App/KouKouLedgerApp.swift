import SwiftUI

@main
struct KouKouLedgerApp: App {
    @StateObject private var session = AppSession()

    var body: some Scene {
        WindowGroup {
            RootView(session: session)
        }
    }
}
