import Dependencies
import LogKit

extension AuthGateway {
    /// Records only this seam's own failures. A response failure has already been logged by the
    /// mapper's decorator, so it passes through untouched rather than being logged twice.
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
