import Foundation

extension URLSession {
    /// The session for requests that carry credentials: bounded waits, and no
    /// response caching, so a session token never reaches a cache.
    public static let api = URLSession(configuration: configuration(cache: nil))

    /// The session behind ``HTTPClient/publicContent``.
    ///
    /// Deliberately not `public`: pairing it with a client is NetworkKit's job,
    /// so no caller can send credentials through a caching session.
    package static let publicContent = URLSession(configuration: configuration(cache: contentCache))

    private static func configuration(cache: URLCache?) -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        configuration.urlCache = cache
        return configuration
    }

    private static let timeout: TimeInterval = 30

    private static let contentCache = URLCache(
        memoryCapacity: 10_000_000,
        diskCapacity: 100_000_000
    )
}
