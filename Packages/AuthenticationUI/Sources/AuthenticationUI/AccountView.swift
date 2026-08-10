import AuthenticationFeature
import SwiftUI

public struct AccountView: View {
    @State private var viewModel = ViewModel()

    public init() {}

    public var body: some View {
        content
            .task { await viewModel.load() }
            .sheet(isPresented: $viewModel.isPresentingSignIn, onDismiss: { Task { await viewModel.load() } }) {
                NavigationStack {
                    SignInView(onSignedIn: { viewModel.dismissSignIn() })
                        .navigationTitle("Sign in")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") { viewModel.dismissSignIn() }
                            }
                        }
                }
            }
    }

    @ViewBuilder private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .signedOut:
            Button("Sign In") { viewModel.presentSignIn() }
        case .signedIn:
            ProfileCard(onSignOut: { Task { await viewModel.load() } })
        }
    }
}

#Preview {
    AccountView()
}
