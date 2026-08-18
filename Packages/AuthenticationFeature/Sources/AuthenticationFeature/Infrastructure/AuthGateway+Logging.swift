import Dependencies
import LogKit

extension AuthGateway {
    func loggingRequestFailures() -> AuthGateway {
        AuthGateway { credential in
            do {
                return try await authenticate(credential)
            } catch let failure as LoginRequestFailure {
                // Resolved per call, so a test overriding \.log is honoured. Resolving it while
                // building liveValue would capture whichever log existed first.
                @Dependency(\.log) var log
                let entry = LoggedLoginFailure(failure)
                log(entry.level, .auth, entry.message)
                throw failure
            }
        }
    }
}
