import Dependencies
import Foundation
import LogKit
import NetworkKit

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
                let entry = LoggedHTTPRequestOutcome.success(
                    request: request,
                    status: response.status
                )
                log(entry.level, .network, entry.message)
                return (data, response)
            } catch {
                let entry = LoggedHTTPRequestOutcome.failure(request: request, error: error)
                log(entry.level, .network, entry.message)
                throw error
            }
        }
    }
}
