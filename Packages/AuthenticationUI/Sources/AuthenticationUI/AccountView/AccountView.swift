import AuthenticationFeature
import SwiftUI

public struct AccountView: View {
    @State private var viewModel = ViewModel()

    public init() {}

    public var body: some View {
        AccountViewContent(
            state: viewModel.state,
            onSignOut: { Task { await viewModel.load() } },
            onSignedIn: { Task { await viewModel.load() } }
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
