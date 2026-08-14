import Dependencies
import Foundation

extension HTTPClient {
    package func authenticated() -> HTTPClient {
        HTTPClient { request in
            @Dependency(\.sessionStore) var sessionStore
            var request = request
            if let session = try? await sessionStore.current() {
                request.setValue("Bearer \(String(session.token))", forHTTPHeaderField: "Authorization")
            }
            return try await self.send(request)
        }
    }
}
