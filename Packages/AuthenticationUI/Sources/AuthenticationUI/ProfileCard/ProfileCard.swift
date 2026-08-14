import AuthenticationFeature
import SwiftUI

package struct ProfileCard: View {
    @State private var viewModel: ViewModel

    package init(onSignOut: @escaping @MainActor () -> Void) {
        _viewModel = State(wrappedValue: ViewModel(onSignOut: onSignOut))
    }

    package var body: some View {
        ProfileCardContent(
            state: viewModel.state,
            retry: { await viewModel.load() },
            signOut: { await viewModel.signOut() }
        )
        .task { await viewModel.load() }
    }
}
