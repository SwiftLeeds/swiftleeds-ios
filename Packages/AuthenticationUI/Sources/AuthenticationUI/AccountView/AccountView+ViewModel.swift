import AuthenticationFeature
import Dependencies
import Observation

extension AccountView {
    @MainActor
    @Observable
    package final class ViewModel {
        package enum State: Equatable {
            case loading
            case signedOut
            case signedIn(SignedInProof)
        }

        @ObservationIgnored
        @Dependency(\.authStatus) private var authStatus

        package private(set) var state: State = .loading
        package var isPresentingSignIn = false

        package init() {}

        package func load() async {
            switch await authStatus.current() {
            case .signedIn(let proof):
                state = .signedIn(proof)
            case .signedOut:
                state = .signedOut
            }
        }

        package func presentSignIn() {
            isPresentingSignIn = true
        }

        package func dismissSignIn() {
            isPresentingSignIn = false
        }
    }
}
