import AuthenticationFeature
import SwiftUI

public struct AccountView: View {
    @State private var viewModel = ViewModel()

    public init() {}

    public var body: some View {
        AccountViewContent(
            state: viewModel.state,
            onSignOut: { reason in Task { await viewModel.signedOut(reason) } },
            onSignedIn: { Task { await viewModel.signedIn() } }
        )
        .task { await viewModel.load() }
    }
}

#Preview {
    NavigationStack {
        List {
            AccountView()
        }
    }
}
