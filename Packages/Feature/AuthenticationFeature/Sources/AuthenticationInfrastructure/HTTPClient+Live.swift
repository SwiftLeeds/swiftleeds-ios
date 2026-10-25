import Dependencies
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
    /// Returns the client for requests that carry the session bearer.
    ///
    /// - Parameters:
    ///   - transport: The client that sends each request. It must not cache
    ///     responses.
    ///   - onSessionExpiry: Called when a bearer-carrying request gets a 401.
    /// - Returns: The transport wrapped in logging, session-expiry interception
    ///   and bearer attachment.
    public static func live(
        transport: HTTPClient,
        onSessionExpiry: @escaping @Sendable () async -> Void,
    ) -> HTTPClient {
        transport
            .logging()
            .interceptingSessionExpiry(onExpiry: onSessionExpiry)
            .authenticated()
    }
}
