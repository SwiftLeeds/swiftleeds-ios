import Dependencies
import Foundation
import NetworkKit

private enum AuthHTTPClientKey: TestDependencyKey {
    static let testValue = HTTPClient(send: unimplemented("authHTTPClient.send"))
}

extension DependencyValues {
    /// The client for requests that carry the signed-in session's bearer.
    ///
    /// Public endpoints use `\.httpClient`, which sends no bearer and does not
    /// sign the user out on a 401.
    public var authHTTPClient: HTTPClient {
        get { self[AuthHTTPClientKey.self] }
        set { self[AuthHTTPClientKey.self] = newValue }
    }
}

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
