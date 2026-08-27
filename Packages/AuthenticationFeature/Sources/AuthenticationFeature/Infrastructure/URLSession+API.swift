import Foundation

extension URLSession {
    /// The session for API calls: bounded waits, and no cached copies of
    /// bearer-fetched responses.
    package static let api: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }()
}
