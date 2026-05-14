import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: AuthViewModel
    let onLogin: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.large) {
                header

                AppCard {
                    VStack(spacing: AppTheme.Spacing.medium) {
                        AppTextField(title: "昵称", placeholder: "例如 小扣", text: $viewModel.nickname, errorText: nil)
                        AppTextField(
                            title: "邮箱",
                            placeholder: "可选",
                            text: $viewModel.email,
                            errorText: nil,
                            keyboardType: .emailAddress,
                            textContentType: .emailAddress
                        )
                        AppTextField(
                            title: "手机号",
                            placeholder: "可选",
                            text: $viewModel.phone,
                            errorText: nil,
                            keyboardType: .phonePad,
                            textContentType: .telephoneNumber
                        )
                        AppSecureField(title: "密码", placeholder: "至少 6 位", text: $viewModel.password, errorText: nil)
                        AppSecureField(title: "确认密码", placeholder: "再次输入密码", text: $viewModel.confirmPassword, errorText: nil)
                        AppButton(
                            "注册并登录",
                            systemImage: "person.crop.circle.badge.plus",
                            isLoading: viewModel.isLoading
                        ) {
                            Task { await viewModel.register() }
                        }
                    }
                }

                Button(action: onLogin) {
                    Text("已有账号？返回登录")
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
            Text("创建账号")
                .font(.largeTitle.bold())
            Text("邮箱和手机号至少填写一个")
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
