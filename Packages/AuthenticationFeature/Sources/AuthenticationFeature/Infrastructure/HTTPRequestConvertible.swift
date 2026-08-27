import Foundation

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
}
