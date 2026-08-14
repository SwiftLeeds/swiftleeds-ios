import AuthenticationFeature
import Dependencies
import Observation

extension AccountView {
    @MainActor
    @Observable
    package final class ViewModel {
        @ObservationIgnored
        @Dependency(\.authStatus) private var authStatus

        package private(set) var state: AccountViewState = .loading
        private var signInRequired = false

        package init() {}

        package func load() async {
            switch await authStatus.current() {
            case .signedIn(let proof):
                state = .signedIn(proof)
            case .signedOut:
                state = .signedOut(signInRequired: signInRequired)
            }
        }

        package func signedOut(_ reason: SignOutReason) async {
            signInRequired = reason == .signInRequired
            await load()
        }

        package func signedIn() async {
            signInRequired = false
            await load()
        }
    }
}
