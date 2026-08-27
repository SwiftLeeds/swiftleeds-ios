import Foundation

extension URLSession {
    /// The session for API calls: bounded waits, and no response caching.
    public static let api: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }()
}
