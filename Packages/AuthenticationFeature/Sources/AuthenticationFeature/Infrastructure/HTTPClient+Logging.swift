import Dependencies
import Foundation
import LogKit

extension HTTPClient {
    package func logging() -> HTTPClient {
        HTTPClient { request in
            do {
                return try await send(request)
            } catch {
                // Resolved per call, so a test overriding \.log is honoured. Resolving it while
                // building liveValue would capture whichever log existed first.
                @Dependency(\.log) var log
                log.error(
                    """
                    A request could not reach the server: \
                    \(request.loggedSummary, name: "request", privacy: .open), \
                    \(error, name: "reason", privacy: .open)
                    """,
                    in: .network
                )
                throw error
            }
        }
    }
}

extension URLRequest {
    /// Method and path only. A query can carry credentials and headers carry the bearer token, so
    /// neither belongs in a log.
    fileprivate var loggedSummary: String {
        [httpMethod, url?.path(percentEncoded: false)]
            .compactMap { $0 }
            .joined(separator: " ")
    }
}
