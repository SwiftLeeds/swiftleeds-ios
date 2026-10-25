import SwiftUI

package struct AccountViewContent: View {
    /// A view that presents the sign-in flow and dismisses itself once someone is signed in.
    private struct SignInDestination: View {
        /// An action that dismisses the presented destination.
        @Environment(\.dismiss) private var dismiss

        /// The action to run when sign-in succeeds.
        let onSignedIn: @MainActor () -> Void

        /// The sign-in flow, titled "Sign In".
        var body: some View {
            SignInView(onSignedIn: {
                onSignedIn()
                dismiss()
            })
            .navigationTitle("Sign In")
        }
    }

    private let state: AccountViewState
    private let onSignOut: @MainActor (SignOutReason) -> Void
    private let onSignedIn: @MainActor () -> Void

    package init(
        state: AccountViewState,
        onSignOut: @escaping @MainActor (SignOutReason) -> Void,
        onSignedIn: @escaping @MainActor () -> Void,
    ) {
        self.state = state
        self.onSignOut = onSignOut
        self.onSignedIn = onSignedIn
    }

    package var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content

            if case .signedOut(signInRequired: true) = state {
                Text("Your sign-in expired. Sign in again to see your account details.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder private var content: some View {
        switch state {
        case .loading:
            NameplatePlaceholder()

        case .signedOut:
            signedOut

        case .signedIn:
            ProfileCard(onSignOut: onSignOut)
        }
    }

    private var signedOut: some View {
        NavigationLink {
            SignInDestination(onSignedIn: onSignedIn)
        } label: {
            Nameplate(Text("Sign In"), role: .unresolved) {
                Avatar(url: nil) {
                    Image(systemName: "person")
                }
            }
        }
    }
}

#Preview("Every state") {
    NavigationStack {
        List {
            AccountViewContent(state: .loading, onSignOut: { _ in }, onSignedIn: {})
            AccountViewContent(state: .signedOut(signInRequired: false), onSignOut: { _ in }, onSignedIn: {})
            AccountViewContent(state: .signedOut(signInRequired: true), onSignOut: { _ in }, onSignedIn: {})
        }
    }
}

#Preview("Signed out, compact") {
    NavigationStack {
        List {
            AccountViewContent(state: .signedOut(signInRequired: true), onSignOut: { _ in }, onSignedIn: {})
        }
        .nameplateStyle(.compact)
    }
}
