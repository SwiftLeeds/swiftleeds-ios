import AuthenticationFeature
import SwiftUI

public struct AccountView: View {
    @State private var viewModel = ViewModel()

    public init() {}

    public var body: some View {
        content
            .task { await viewModel.load() }
    }

    @ViewBuilder private var content: some View {
        switch viewModel.state {
        case .loading:
            NameplatePlaceholder()
        case .signedOut:
            signedOut
        case .signedIn:
            ProfileCard(onSignOut: { Task { await viewModel.load() } })
        }
    }

    private var signedOut: some View {
        NavigationLink {
            SignInDestination(onSignedIn: { Task { await viewModel.load() } })
        } label: {
            Nameplate(Text("Sign in"), role: .unresolved) {
                Avatar(url: nil) {
                    Image(systemName: "person")
                }
            }
        }
    }
}

private struct SignInDestination: View {
    @Environment(\.dismiss) private var dismiss

    let onSignedIn: @MainActor () -> Void

    var body: some View {
        SignInView(onSignedIn: {
            onSignedIn()
            dismiss()
        })
        .navigationTitle("Sign in")
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        List {
            AccountView()
        }
    }
}
#endif
