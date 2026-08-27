import Foundation

extension HTTPClient {
    public static func live(
        urlSession: URLSession = .api,
        onSessionExpiry: @escaping @Sendable () async -> Void
    ) -> HTTPClient {
        HTTPClient.urlSession(urlSession)
            .logging()
            .interceptingSessionExpiry(onExpiry: onSessionExpiry)
            .authenticated()
    }
}
