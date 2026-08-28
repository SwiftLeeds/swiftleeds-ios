import Foundation
import NetworkKit

extension HTTPClient {
    /// The composed client the app uses: transport, transport logging,
    /// session-expiry interception and bearer attachment.
    ///
    /// - Parameters:
    ///   - urlSession: The transport session. Defaults to the configured API
    ///     session; a test passes a stubbed one.
    ///   - onSessionExpiry: Called when a bearer-carrying request gets a 401.
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
