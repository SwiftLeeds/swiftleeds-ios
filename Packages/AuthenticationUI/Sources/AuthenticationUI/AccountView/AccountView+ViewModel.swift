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

        package init() {}

        package func load() async {
            switch await authStatus.current() {
            case .signedIn(let proof):
                state = .signedIn(proof)
            case .signedOut:
                state = .signedOut
            }
        }
    }
}
