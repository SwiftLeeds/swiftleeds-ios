import Foundation

/// One HTTP request, described by its method, path and content.
///
/// The constructors follow RFC 9110's content semantics: only `post`, `put`
/// and `patch` take content, so a GET cannot carry any.
public struct HTTPRequest: Equatable, Hashable, Sendable {
    private let method: HTTPMethod
    private let path: URLPath
    private let content: HTTPContent?

    public static func get(_ path: URLPath) -> HTTPRequest {
        HTTPRequest(method: .get, path: path, content: nil)
    }

    public static func head(_ path: URLPath) -> HTTPRequest {
        HTTPRequest(method: .head, path: path, content: nil)
    }

    public static func post(_ path: URLPath, content: HTTPContent) -> HTTPRequest {
        HTTPRequest(method: .post, path: path, content: content)
    }

    public static func put(_ path: URLPath, content: HTTPContent) -> HTTPRequest {
        HTTPRequest(method: .put, path: path, content: content)
    }

    public static func delete(_ path: URLPath) -> HTTPRequest {
        HTTPRequest(method: .delete, path: path, content: nil)
    }

    public static func connect(_ path: URLPath) -> HTTPRequest {
        HTTPRequest(method: .connect, path: path, content: nil)
    }

    public static func options(_ path: URLPath) -> HTTPRequest {
        HTTPRequest(method: .options, path: path, content: nil)
    }

    public static func trace(_ path: URLPath) -> HTTPRequest {
        HTTPRequest(method: .trace, path: path, content: nil)
    }

    public static func patch(_ path: URLPath, content: HTTPContent) -> HTTPRequest {
        HTTPRequest(method: .patch, path: path, content: content)
    }

    /// Builds the `URLRequest` this value describes.
    ///
    /// - Parameter baseURL: The server root the path is appended to.
    public func urlRequest(baseURL: URL) -> URLRequest {
        var request = URLRequest(url: baseURL.appending(path: String(path)))
        request.httpMethod = method.rawValue
        content?.attach(to: &request)
        return request
    }
}
