import AuthenticationFeature
import Foundation
import SwiftUI

package struct AccountDetailView: View {
    private let profile: Profile
    private let signOut: @MainActor () async -> Void

    package init(
        profile: Profile,
        signOut: @escaping @MainActor () async -> Void
    ) {
        self.profile = profile
        self.signOut = signOut
    }

    package var body: some View {
        List {
            Section {
                VStack(spacing: 8) {
                    Avatar(url: profile.avatarURL) {
                        Text(verbatim: Initials.from(profile.name))
                    }
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 88, height: 88)

                    Text(verbatim: profile.name.formatted())
                        .font(.title2.weight(.semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }

            Section {
                LabeledContent("Email") {
                    Text(verbatim: profile.emailAddress)
                }
                LabeledContent("Ticket Reference") {
                    Text(verbatim: profile.ticketReference)
                }
            }

            Section {
                SignOutButton(signOut: signOut)
            }
        }
        .navigationTitle(profile.name.formatted())
        .inlineNavigationTitle()
    }
}

private extension View {
    func inlineNavigationTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        AccountDetailView(profile: .preview, signOut: {})
    }
}
#endif
