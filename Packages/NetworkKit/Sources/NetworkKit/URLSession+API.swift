import Foundation

extension URLSession {
    /// The session for API calls: bounded waits, and no response caching.
    ///
    /// Authenticated requests use this one, so a response carrying a session
    /// token is never written to a cache.
    public static let api = URLSession(configuration: configuration(cache: nil))

    /// The session for public content: the same limits, plus a response cache.
    ///
    /// The cache stores only what the server marks cacheable, so it holds
    /// nothing until the API sends `Cache-Control`.
    public static let content = URLSession(configuration: configuration(cache: contentCache))

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
