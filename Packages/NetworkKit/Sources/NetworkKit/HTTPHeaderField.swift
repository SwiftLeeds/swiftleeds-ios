import Foundation

/// One HTTP header field, as a name and value pair.
public struct HTTPHeaderField: Equatable, Hashable, Sendable {
    /// A field name. Case-insensitive, so `Accept` and `accept` are one name.
    ///
    /// `String(name)` gives back the casing you wrote. Every field RFC 9110 and
    /// RFC 9111 define is a constant. Anything else, such as CORS, cookies and
    /// WebSocket, uses `init(_:)`.
    public struct Name: Equatable, Hashable, Sendable {
        fileprivate let value: String

        /// Creates a field name the constants below do not cover.
        ///
        /// - Parameter value: The name as spelled on the wire, such as
        ///   `X-Conference`.
        public init(_ value: String) {
            self.value = value
        }

        /// Compares two names ignoring case.
        public static func == (lhs: Name, rhs: Name) -> Bool {
            lhs.value.lowercased() == rhs.value.lowercased()
        }

        /// Hashes the name ignoring case.
        public func hash(into hasher: inout Hasher) {
            hasher.combine(value.lowercased())
        }
    }

    /// A field value. Sent exactly as written, and case-sensitive.
    public struct Value: Equatable, Hashable, Sendable {
        fileprivate let value: String

        /// Creates a field value.
        ///
        /// - Parameter value: The value as sent. Nothing is escaped or encoded
        ///   for you.
        public init(_ value: String) {
            self.value = value
        }
    }

    /// The field's name.
    private let name: Name
    /// The field's value.
    private let value: Value

    /// Creates a header field.
    init(name: Name, value: Value) {
        self.name = name
        self.value = value
    }

    /// Sets this field on the request.
    /// - Parameter request: The request to set the field on.
    func attach(to request: inout URLRequest) {
        request.setValue(String(value), forHTTPHeaderField: String(name))
    }
}

extension HTTPHeaderField.Name {
    /// The media types the client accepts in a response.
    public static let accept = HTTPHeaderField.Name("Accept")
    /// The content codings the client accepts.
    public static let acceptEncoding = HTTPHeaderField.Name("Accept-Encoding")
    /// The languages the client prefers.
    public static let acceptLanguage = HTTPHeaderField.Name("Accept-Language")
    /// The range units the server supports.
    public static let acceptRanges = HTTPHeaderField.Name("Accept-Ranges")
    /// How long the response sat in a cache, in seconds.
    public static let age = HTTPHeaderField.Name("Age")
    /// The methods the resource supports.
    public static let allow = HTTPHeaderField.Name("Allow")
    /// Authentication details after a successful request.
    public static let authenticationInfo = HTTPHeaderField.Name("Authentication-Info")
    /// The credentials for the requested resource.
    public static let authorization = HTTPHeaderField.Name("Authorization")
    /// Directives for caches along the path.
    public static let cacheControl = HTTPHeaderField.Name("Cache-Control")
    /// Options for the current connection.
    public static let connection = HTTPHeaderField.Name("Connection")
    /// The codings applied to the body.
    public static let contentEncoding = HTTPHeaderField.Name("Content-Encoding")
    /// The languages of the body.
    public static let contentLanguage = HTTPHeaderField.Name("Content-Language")
    /// The size of the body, in bytes.
    public static let contentLength = HTTPHeaderField.Name("Content-Length")
    /// A URI for the body as a resource.
    public static let contentLocation = HTTPHeaderField.Name("Content-Location")
    /// Where a partial body sits in the full resource.
    public static let contentRange = HTTPHeaderField.Name("Content-Range")
    /// The media type of the body.
    public static let contentType = HTTPHeaderField.Name("Content-Type")
    /// When the message was created.
    public static let date = HTTPHeaderField.Name("Date")
    /// The version tag of the resource.
    public static let eTag = HTTPHeaderField.Name("ETag")
    /// What the client needs before sending the body.
    public static let expect = HTTPHeaderField.Name("Expect")
    /// When the response goes stale.
    public static let expires = HTTPHeaderField.Name("Expires")
    /// The email address of the person behind the request.
    public static let from = HTTPHeaderField.Name("From")
    /// The host and port the request is for.
    public static let host = HTTPHeaderField.Name("Host")
    /// The resource tags that allow the request.
    public static let ifMatch = HTTPHeaderField.Name("If-Match")
    /// The date the resource must have changed after.
    public static let ifModifiedSince = HTTPHeaderField.Name("If-Modified-Since")
    /// The resource tags that block the request.
    public static let ifNoneMatch = HTTPHeaderField.Name("If-None-Match")
    /// The tag or date the resource must still match for a range.
    public static let ifRange = HTTPHeaderField.Name("If-Range")
    /// The date the resource must be unchanged since.
    public static let ifUnmodifiedSince = HTTPHeaderField.Name("If-Unmodified-Since")
    /// When the resource last changed.
    public static let lastModified = HTTPHeaderField.Name("Last-Modified")
    /// Where to find the resource or the result.
    public static let location = HTTPHeaderField.Name("Location")
    /// How many proxies may forward the request.
    public static let maxForwards = HTTPHeaderField.Name("Max-Forwards")
    /// How to authenticate with the proxy.
    public static let proxyAuthenticate = HTTPHeaderField.Name("Proxy-Authenticate")
    /// Proxy authentication details after success.
    public static let proxyAuthenticationInfo = HTTPHeaderField.Name("Proxy-Authentication-Info")
    /// The credentials for the proxy.
    public static let proxyAuthorization = HTTPHeaderField.Name("Proxy-Authorization")
    /// The part of the resource the client wants.
    public static let range = HTTPHeaderField.Name("Range")
    /// The URI the request came from.
    public static let referer = HTTPHeaderField.Name("Referer")
    /// How long to wait before trying again.
    public static let retryAfter = HTTPHeaderField.Name("Retry-After")
    /// The software that produced the response.
    public static let server = HTTPHeaderField.Name("Server")
    /// The transfer codings the client accepts.
    public static let te = HTTPHeaderField.Name("TE")
    /// The fields that follow the body.
    public static let trailer = HTTPHeaderField.Name("Trailer")
    /// The protocols the sender would switch to.
    public static let upgrade = HTTPHeaderField.Name("Upgrade")
    /// The software that sent the request.
    public static let userAgent = HTTPHeaderField.Name("User-Agent")
    /// The request fields that chose this response.
    public static let vary = HTTPHeaderField.Name("Vary")
    /// The proxies the message passed through.
    public static let via = HTTPHeaderField.Name("Via")
    /// How to authenticate with the resource.
    public static let wwwAuthenticate = HTTPHeaderField.Name("WWW-Authenticate")
}

extension HTTPHeaderField.Value: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension String {
    /// Creates the header name's spelling, with the casing it was given.
    ///
    /// - Parameter name: The name to read.
    public init(_ name: HTTPHeaderField.Name) {
        self = name.value
    }

    /// Creates the header value's text.
    ///
    /// - Parameter value: The value to read.
    public init(_ value: HTTPHeaderField.Value) {
        self = value.value
    }
}
