import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    let onRegister: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                header

                AppCard {
                    VStack(spacing: AppTheme.Spacing.medium) {
                        AppTextField(
                            title: "账号",
                            placeholder: "邮箱或手机号",
                            text: $viewModel.account,
                            errorText: nil,
                            keyboardType: .emailAddress,
                            textContentType: .username
                        )
                        AppSecureField(
                            title: "密码",
                            placeholder: "请输入密码",
                            text: $viewModel.password,
                            errorText: nil
                        )
                        AppButton(
                            "登录",
                            systemImage: "arrow.right.circle.fill",
                            isLoading: viewModel.isLoading
                        ) {
                            Task { await viewModel.login() }
                        }
                    }
                }

                Button(action: onRegister) {
                    Text("还没有账号？注册")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color.accentColor)
            }
            .padding(AppTheme.Spacing.large)
        }
        .alert("提示", isPresented: alertBinding) {
            Button("好", role: .cancel) {
                viewModel.alertMessage = nil
            }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text("抠抠记账")
                .font(.largeTitle.bold())
            Text("登录后继续管理你的账本")
                .foregroundStyle(.secondary)
        }
        .padding(.top, AppTheme.Spacing.xLarge)
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alertMessage != nil },
            set: { if !$0 { viewModel.alertMessage = nil } }
        )
    }
}
