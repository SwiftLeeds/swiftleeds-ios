import Foundation

/// One HTTP request, described by its method, path and content.
///
/// The constructors follow RFC 9110's content semantics: only `post`, `put`
/// and `patch` take content, so a GET cannot carry any.
public struct HTTPRequest: Equatable, Hashable, Sendable {
    private let method: HTTPMethod
    private let path: URLPath
    private let content: HTTPContent?
    private let queryItems: [URLQueryItem]
    private let fields: [HTTPField]

    private init(
        method: HTTPMethod,
        path: URLPath,
        content: HTTPContent?,
        queryItems: [URLQueryItem] = [],
        fields: [HTTPField] = []
    ) {
        self.method = method
        self.path = path
        self.content = content
        self.queryItems = queryItems
        self.fields = fields
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

    /// Returns a copy carrying the given query items after any it already holds.
    ///
    /// - Parameter queryItems: The items to append. An empty array changes nothing.
    public func appending(queryItems: [URLQueryItem]) -> HTTPRequest {
        HTTPRequest(
            method: method,
            path: path,
            content: content,
            queryItems: self.queryItems + queryItems,
            fields: fields
        )
    }

    /// Returns a copy carrying the given field after any it already holds.
    ///
    /// - Parameters:
    ///   - name: The field name. A later field of the same name replaces an earlier one.
    ///   - value: The data to send under that name.
    public func appending(field name: HTTPField.Name, _ value: HTTPField.Value) -> HTTPRequest {
        HTTPRequest(
            method: method,
            path: path,
            content: content,
            queryItems: queryItems,
            fields: fields + [HTTPField(name: name, value: value)]
        )
    }

    /// Returns a copy carrying the given media type under the given field name.
    ///
    /// - Parameters:
    ///   - name: The field name. A later field of the same name replaces an earlier one.
    ///   - mediaType: The media type to send under that name.
    public func appending(field name: HTTPField.Name, _ mediaType: MediaType) -> HTTPRequest {
        appending(field: name, HTTPField.Value(String(mediaType)))
    }

    /// Builds the `URLRequest` this value describes.
    ///
    /// Content writes its own Content-Type last, so it wins over a field of that name.
    ///
    /// - Parameter baseURL: The server root the path is appended to.
    public func urlRequest(baseURL: URL) -> URLRequest {
        var request = URLRequest(url: url(baseURL: baseURL))
        request.httpMethod = method.rawValue
        for field in fields {
            field.attach(to: &request)
        }
        content?.attach(to: &request)
        return request
    }

    private func url(baseURL: URL) -> URL {
        let resource = baseURL.appending(path: String(path))
        // Foundation appends a bare "?" for an empty array, so the guard is load-bearing.
        guard !queryItems.isEmpty else { return resource }
        return resource.appending(queryItems: queryItems)
    }
}
