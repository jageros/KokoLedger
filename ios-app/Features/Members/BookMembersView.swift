import SwiftUI

struct BookMembersView: View {
    @ObservedObject private var session: AppSession
    @StateObject private var viewModel: MembersViewModel
    @State private var showingInvite = false
    @State private var showingAcceptInvite = false
    @State private var editingMember: BookMemberDisplay?

    init(session: AppSession) {
        self.session = session
        _viewModel = StateObject(wrappedValue: MembersViewModel(session: session))
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.members.isEmpty {
                LoadingView(message: "加载成员")
            } else if viewModel.members.isEmpty {
                EmptyStateView(
                    title: "暂无成员",
                    message: "成员加入后会显示在这里。",
                    systemImage: "person.2"
                )
            } else {
                List {
                    ForEach(viewModel.members) { display in
                        MemberRowView(
                            display: display,
                            book: session.currentBook,
                            currentUserId: session.currentUser?.id,
                            canManage: viewModel.canManageMembers,
                            onEditRole: { editingMember = display },
                            onRemove: {
                                Task { await viewModel.removeMember(display.member) }
                            }
                        )
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("成员管理")
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showingAcceptInvite = true
                } label: {
                    Image(systemName: "person.badge.plus")
                }
                if viewModel.canManageMembers {
                    Button {
                        showingInvite = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .task {
            await viewModel.loadMembers()
        }
        .refreshable {
            await viewModel.loadMembers()
        }
        .sheet(isPresented: $showingInvite) {
            InviteMemberView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showingAcceptInvite) {
            AcceptInviteView(session: session)
                .presentationDetents([.medium])
        }
        .sheet(item: $editingMember) { display in
            PermissionEditView(viewModel: viewModel, display: display)
                .presentationDetents([.medium])
        }
        .alert("提示", isPresented: alertBinding) {
            Button("好", role: .cancel) {
                viewModel.alertMessage = nil
            }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
    }

    private var alertBinding: Binding<Bool> {
        Binding(
            get: { viewModel.alertMessage != nil },
            set: { if !$0 { viewModel.alertMessage = nil } }
        )
    }
}
