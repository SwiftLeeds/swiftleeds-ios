import Dependencies
import Foundation
import LogKit

extension HTTPClient {
    /// Records what came back, then returns or rethrows.
    ///
    /// Every request in the app passes through here, so this is the one seam that knows which
    /// endpoint was called and what the server answered.
    package func logging() -> HTTPClient {
        HTTPClient { request in
            // Resolved per call, so a test overriding \.log is honoured. Resolving it while
            // building liveValue would capture whichever log existed first.
            @Dependency(\.log) var log
            do {
                let (data, response) = try await send(request)
                let entry = LoggedRequestOutcome.success(
                    request: request.loggedSummary,
                    statusCode: response.statusCode
                )
                log(entry.level, .network, entry.message)
                return (data, response)
            } catch {
                let entry = LoggedRequestOutcome.failure(request: request.loggedSummary, error: error)
                log(entry.level, .network, entry.message)
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
