import Dependencies
import Foundation
import LogKit

extension LoginMapper {
    /// Wraps the mapper rather than the gateway, which has already narrowed the failure to
    /// `AuthenticationError` and lost the reason.
    func loggingFailures() -> LoginMapper {
        LoginMapper { data, response throws(LoginResponseFailure) in
            do throws(LoginResponseFailure) {
                return try map(data, response)
            } catch {
                // Resolved per call, so a test overriding \.log is honoured. Resolving it while
                // building liveValue would capture whichever log existed first.
                @Dependency(\.log) var log
                log(error.level, .auth, "Sign-in was refused: \(error, name: "reason", privacy: .open)")
                throw error
            }
        }
    }
}

extension LoginResponseFailure {
    /// A rejected credential is an expected outcome, not a fault in the app; anything else is.
    var level: LogLevel {
        switch self {
        case .invalidCredentials:
            .notice
        case .unexpectedStatus:
            .error
        }
    }
}
