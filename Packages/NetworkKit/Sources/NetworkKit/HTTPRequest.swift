import Foundation

/// One HTTP request: a method, a path, query items, headers and content.
///
/// Only `post`, `put` and `patch` take content. A GET cannot carry any.
public struct HTTPRequest: Equatable, Hashable, Sendable {
    private let method: HTTPMethod
    private let path: URLPath
    private let content: HTTPContent?
    private let queryItems: [URLQueryItem]
    private let headerFields: [HTTPHeaderField]

    private init(
        method: HTTPMethod,
        path: URLPath,
        content: HTTPContent?,
        queryItems: [URLQueryItem] = [],
        headerFields: [HTTPHeaderField] = []
    ) {
        self.method = method
        self.path = path
        self.content = content
        self.queryItems = queryItems
        self.headerFields = headerFields
    }

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

    /// Adds query items to the end of the query string.
    ///
    /// - Parameter queryItems: Items to append. An empty array is a no-op.
    /// - Returns: A copy. This request is unchanged.
    public func appending(queryItems: [URLQueryItem]) -> HTTPRequest {
        HTTPRequest(
            method: method,
            path: path,
            content: content,
            queryItems: self.queryItems + queryItems,
            headerFields: headerFields
        )
    }

    /// Adds a header field.
    ///
    /// - Parameters:
    ///   - name: Field name. Appending the same name twice keeps the last value.
    ///   - value: Field value, sent exactly as written.
    /// - Returns: A copy. This request is unchanged.
    public func appending(headerField name: HTTPHeaderField.Name, _ value: HTTPHeaderField.Value) -> HTTPRequest {
        HTTPRequest(
            method: method,
            path: path,
            content: content,
            queryItems: queryItems,
            headerFields: headerFields + [HTTPHeaderField(name: name, value: value)]
        )
    }

    /// Adds a header field whose value is a media type.
    ///
    /// - Parameters:
    ///   - name: Field name. Appending the same name twice keeps the last value.
    ///   - mediaType: Media type to send, such as `.application.json`.
    /// - Returns: A copy. This request is unchanged.
    public func appending(headerField name: HTTPHeaderField.Name, _ mediaType: MediaType) -> HTTPRequest {
        appending(headerField: name, HTTPHeaderField.Value(String(mediaType)))
    }

    /// Builds the `URLRequest` this describes.
    ///
    /// Content sets its own `Content-Type`, beating any you appended.
    ///
    /// - Parameter baseURL: Server root. The path is appended to it.
    /// - Returns: The built request, ready to send.
    public func urlRequest(baseURL: URL) -> URLRequest {
        var request = URLRequest(url: url(baseURL: baseURL))
        request.httpMethod = method.rawValue
        for headerField in headerFields {
            headerField.attach(to: &request)
        }
        content?.attach(to: &request)
        return request
    }

    private func url(baseURL: URL) -> URL {
        let resource = baseURL.appending(path: String(path))
        guard !queryItems.isEmpty else { return resource }
        return resource.appending(queryItems: queryItems)
    }
}
