import AuthenticationFeature
import SwiftUI

package struct ProfileCardContent: View {
    private let state: ProfileCardState
    private let retry: @MainActor () async -> Void
    private let signOut: @MainActor () async -> Void

    package init(
        state: ProfileCardState,
        retry: @escaping @MainActor () async -> Void,
        signOut: @escaping @MainActor () async -> Void
    ) {
        self.state = state
        self.retry = retry
        self.signOut = signOut
    }

    package var body: some View {
        switch state {
        case .loading:
            NameplatePlaceholder()
        case .loaded(let profile):
            loaded(profile)
        case .failed:
            failed
        }
    }

    private func loaded(_ profile: Profile) -> some View {
        NavigationLink {
            AccountDetailView(profile: profile, signOut: signOut)
        } label: {
            Nameplate(
                Text(verbatim: profile.name),
                detail: Text(verbatim: profile.emailAddress)
            ) {
                Avatar(url: profile.avatarURL) {
                    Text(verbatim: Initials.from(profile.name))
                }
            }
        }
    }

    private var failed: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("We couldn't load your profile.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 24) { actions }
                VStack(alignment: .leading, spacing: 12) { actions }
            }
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder private var actions: some View {
        Button("Try Again") {
            Task { await retry() }
        }

        SignOutButton(signOut: signOut)
    }
}

#if DEBUG
#Preview("Every state") {
    NavigationStack {
        List {
            ProfileCardContent(state: .loading, retry: {}, signOut: {})
            ProfileCardContent(state: .loaded(.preview), retry: {}, signOut: {})
            ProfileCardContent(state: .failed, retry: {}, signOut: {})
        }
    }
}

#Preview("Every state, compact") {
    NavigationStack {
        List {
            ProfileCardContent(state: .loading, retry: {}, signOut: {})
            ProfileCardContent(state: .loaded(.preview), retry: {}, signOut: {})
            ProfileCardContent(state: .failed, retry: {}, signOut: {})
        }
        .nameplateStyle(.compact)
    }
}
#endif
