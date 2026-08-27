import Foundation

extension HTTPClient {
    package func interceptingSessionExpiry(onExpiry: @escaping @Sendable () async -> Void) -> HTTPClient {
        HTTPClient { request in
            let (data, response) = try await self.send(request)
            if response.status == .unauthorized, request.value(forHTTPHeaderField: "Authorization") != nil {
                await onExpiry()
            }
            return (data, response)
        }
    }
}
