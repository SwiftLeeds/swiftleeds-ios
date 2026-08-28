import Foundation

/// One HTTP request, described by its method, path and content.
///
/// The constructors follow RFC 9110's content semantics: a method with no
/// defined content takes no body, so a GET cannot carry one.
public struct HTTPRequest: Equatable, Hashable, Sendable {
    private let method: HTTPMethod
    private let path: URLPath
    private let body: HTTPBody?

    public static func get(_ path: URLPath) -> HTTPRequest {
        HTTPRequest(method: .get, path: path, body: nil)
    }

    public static func head(_ path: URLPath) -> HTTPRequest {
        HTTPRequest(method: .head, path: path, body: nil)
    }

    public static func post(_ path: URLPath, body: HTTPBody) -> HTTPRequest {
        HTTPRequest(method: .post, path: path, body: body)
    }

    public static func put(_ path: URLPath, body: HTTPBody) -> HTTPRequest {
        HTTPRequest(method: .put, path: path, body: body)
    }

    public static func delete(_ path: URLPath) -> HTTPRequest {
        HTTPRequest(method: .delete, path: path, body: nil)
    }

    public static func connect(_ path: URLPath) -> HTTPRequest {
        HTTPRequest(method: .connect, path: path, body: nil)
    }

    public static func options(_ path: URLPath) -> HTTPRequest {
        HTTPRequest(method: .options, path: path, body: nil)
    }

    public static func trace(_ path: URLPath) -> HTTPRequest {
        HTTPRequest(method: .trace, path: path, body: nil)
    }

    public static func patch(_ path: URLPath, body: HTTPBody) -> HTTPRequest {
        HTTPRequest(method: .patch, path: path, body: body)
    }

    /// Builds the `URLRequest` this value describes.
    ///
    /// - Parameter baseURL: The server root the path is appended to.
    public func urlRequest(baseURL: URL) -> URLRequest {
        var request = URLRequest(url: baseURL.appending(path: String(path)))
        request.httpMethod = method.rawValue
        body?.attach(to: &request)
        return request
    }
}
