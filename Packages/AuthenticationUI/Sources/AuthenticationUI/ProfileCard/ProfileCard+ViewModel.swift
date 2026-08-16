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
        @Dependency(\.signOut) private var _signOut

        package private(set) var state: ProfileCardState = .loading
        private let onSignOut: @MainActor (SignOutReason) -> Void

        package init(onSignOut: @escaping @MainActor (SignOutReason) -> Void) {
            self.onSignOut = onSignOut
        }

        package func load() async {
            state = .loading
            do throws(AttendeeFetchError) {
                state = .loaded(try await fetchProfile())
            } catch {
                switch error {
                case .unauthorized:
                    onSignOut(.signInRequired)
                case .invalidResponse, .unknown:
                    state = .failed
                }
            }
        }

        package func signOut() async {
            try? await _signOut()
            onSignOut(.userRequested)
        }
    }
}
