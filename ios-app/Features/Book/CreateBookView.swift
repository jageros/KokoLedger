import SwiftUI

struct CreateBookView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: BookViewModel
    @State private var name = ""
    @State private var note = ""
    @State private var defaultCurrencyCode = "CNY"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("账本名称", text: $name)
                    TextField("备注", text: $note, axis: .vertical)
                    TextField("默认币种", text: $defaultCurrencyCode)
                        .textInputAutocapitalization(.characters)
                }
            }
            .navigationTitle("创建账本")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await viewModel.createBook(
                                name: name,
                                note: note,
                                defaultCurrencyCode: defaultCurrencyCode
                            )
                            if viewModel.alertMessage == nil {
                                dismiss()
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("创建")
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                }
            }
        }
    }
}
