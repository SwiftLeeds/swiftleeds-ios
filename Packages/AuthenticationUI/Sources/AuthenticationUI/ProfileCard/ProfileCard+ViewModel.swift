import AuthenticationFeature
import Dependencies
import Observation

extension ProfileCard {
    @MainActor
    @Observable
    package final class ViewModel {
        @ObservationIgnored
        @Dependency(\.fetchProfile) private var fetchProfile
        @ObservationIgnored
        @Dependency(\.signOut) private var signOut

        package private(set) var state: ProfileCardState = .loading
        private let onSignOut: @MainActor () -> Void

        package init(onSignOut: @escaping @MainActor () -> Void) {
            self.onSignOut = onSignOut
        }

        package func load() async {
            state = .loading
            do {
                state = .loaded(try await fetchProfile())
            } catch {
                state = .failed
            }
        }

        package func performSignOut() async {
            try? await signOut()
            onSignOut()
        }
    }
}
