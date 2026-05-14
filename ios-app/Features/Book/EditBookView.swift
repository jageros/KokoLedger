import SwiftUI

struct EditBookView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: BookViewModel
    let book: Book
    @State private var name: String
    @State private var note: String
    @State private var defaultCurrencyCode: String

    init(viewModel: BookViewModel, book: Book) {
        self.viewModel = viewModel
        self.book = book
        _name = State(initialValue: book.name)
        _note = State(initialValue: book.note ?? "")
        _defaultCurrencyCode = State(initialValue: book.defaultCurrencyCode)
    }

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
            .navigationTitle("编辑账本")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await viewModel.editBook(
                                book,
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
                            Text("保存")
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                }
            }
        }
    }
}
