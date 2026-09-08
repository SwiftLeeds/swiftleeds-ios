import Foundation

extension URLSessionConfiguration {
    /// A configuration for API calls: bounded waits, and no response storage
    /// unless a cache is given.
    ///
    /// - Parameters:
    ///   - timeout: The limit on one request, and on the whole transfer.
    ///   - cache: Where responses are stored. `nil` stores none.
    /// - Returns: A fresh configuration. Callers own what they do with it.
    public static func api(
        timeout: TimeInterval = 30,
        cache: URLCache? = nil
    ) -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        configuration.urlCache = cache
        return configuration
    }
}
