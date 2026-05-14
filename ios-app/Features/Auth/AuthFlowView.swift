import SwiftUI

struct AuthFlowView: View {
    @StateObject private var viewModel: AuthViewModel
    @State private var mode: AuthMode = .login

    init(session: AppSession) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(session: session))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                Group {
                    switch mode {
                    case .login:
                        LoginView(viewModel: viewModel) {
                            withAnimation(AppAnimation.card) {
                                mode = .register
                            }
                        }
                    case .register:
                        RegisterView(viewModel: viewModel) {
                            withAnimation(AppAnimation.card) {
                                mode = .login
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: mode == .login ? .leading : .trailing)))
            }
        }
    }
}

private enum AuthMode {
    case login
    case register
}
