import Foundation

/// One HTTP request, described by its method, path and content.
///
/// The constructors follow RFC 9110's content semantics: a method with no
/// defined content takes no body, so a GET cannot carry one.
package struct HTTPRequest: Equatable, Hashable, Sendable {
    private let method: HTTPMethod
    private let path: URLPath
    private let body: HTTPBody?

    package static func get(_ path: URLPath) -> HTTPRequest {
        HTTPRequest(method: .get, path: path, body: nil)
    }

    package static func post(_ path: URLPath, body: HTTPBody) -> HTTPRequest {
        HTTPRequest(method: .post, path: path, body: body)
    }

    /// Builds the `URLRequest` this value describes.
    ///
    /// - Parameter baseURL: The server root the path is appended to.
    package func urlRequest(baseURL: URL) -> URLRequest {
        var request = URLRequest(url: baseURL.appending(path: String(path)))
        request.httpMethod = method.rawValue
        body?.attach(to: &request)
        return request
    }
}
