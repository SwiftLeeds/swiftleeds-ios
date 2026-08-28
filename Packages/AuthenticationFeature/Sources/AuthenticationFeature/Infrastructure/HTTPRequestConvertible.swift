import Dependencies
import Foundation
import NetworkKit

/// A value that describes itself as one HTTP request.
package protocol HTTPRequestConvertible {
    var request: HTTPRequest { get }
}

extension HTTPRequestConvertible {
    /// Builds the `URLRequest` for ``request``.
    ///
    /// - Parameter baseURL: The server root the path is appended to.
    package func urlRequest(baseURL: URL) -> URLRequest {
        request.urlRequest(baseURL: baseURL)
    }

    /// Builds the `URLRequest` for ``request`` against the configured API's base URL.
    package func urlRequest() -> URLRequest {
        @Dependency(\.apiConfiguration) var apiConfiguration
        return urlRequest(baseURL: apiConfiguration.baseURL)
    }
}
