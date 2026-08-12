import AuthenticationFeature
import SwiftUI

package struct ProfileCard: View {
    @State private var viewModel: ViewModel

    package init(onSignOut: @escaping @MainActor () -> Void) {
        _viewModel = State(wrappedValue: ViewModel(onSignOut: onSignOut))
    }

    package var body: some View {
        content
            .task { await viewModel.load() }
    }

    @ViewBuilder private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .loaded(let profile):
            loaded(profile)
        case .failed:
            VStack(spacing: 12) {
                Text("We couldn't load your profile.")
                    .foregroundStyle(.secondary)
                Button("Try Again") {
                    Task { await viewModel.load() }
                }
            }
        }
    }

    private func loaded(_ profile: Profile) -> some View {
        VStack(spacing: 12) {
            AsyncImage(url: profile.avatarURL) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())

            Text(profile.name)
                .font(.headline)
            Text(profile.emailAddress)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Sign Out", role: .destructive) {
                Task { await viewModel.performSignOut() }
            }
        }
    }
}
