import Foundation

/// One HTTP header field, as a name and value pair.
public struct HTTPHeaderField: Equatable, Hashable, Sendable {
    /// A field name. Case-insensitive, so `Accept` and `accept` are one name.
    ///
    /// `String(name)` gives back the casing you wrote.
    public struct Name: Equatable, Hashable, Sendable {
        fileprivate let value: String

        /// Creates a field name the constants below do not cover.
        ///
        /// - Parameter value: The name as spelled on the wire, such as `X-Conference`.
        public init(_ value: String) {
            self.value = value
        }

        public static func == (lhs: Name, rhs: Name) -> Bool {
            lhs.value.lowercased() == rhs.value.lowercased()
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(value.lowercased())
        }
    }

    /// A field value. Sent exactly as written, and case-sensitive.
    public struct Value: Equatable, Hashable, Sendable {
        fileprivate let value: String

        /// Creates a field value.
        ///
        /// - Parameter value: The value as sent. Nothing is escaped or encoded for you.
        public init(_ value: String) {
            self.value = value
        }
    }

    private let name: Name
    private let value: Value

    init(name: Name, value: Value) {
        self.name = name
        self.value = value
    }

    func attach(to request: inout URLRequest) {
        request.setValue(String(value), forHTTPHeaderField: String(name))
    }
}

// Every header field RFC 9110 and RFC 9111 define. Anything else, including
// CORS, cookies and WebSocket: `HTTPHeaderField.Name("X-Whatever")`.
extension HTTPHeaderField.Name {
    public static let accept = HTTPHeaderField.Name("Accept")
    public static let acceptEncoding = HTTPHeaderField.Name("Accept-Encoding")
    public static let acceptLanguage = HTTPHeaderField.Name("Accept-Language")
    public static let acceptRanges = HTTPHeaderField.Name("Accept-Ranges")
    public static let age = HTTPHeaderField.Name("Age")
    public static let allow = HTTPHeaderField.Name("Allow")
    public static let authenticationInfo = HTTPHeaderField.Name("Authentication-Info")
    public static let authorization = HTTPHeaderField.Name("Authorization")
    public static let cacheControl = HTTPHeaderField.Name("Cache-Control")
    public static let connection = HTTPHeaderField.Name("Connection")
    public static let contentEncoding = HTTPHeaderField.Name("Content-Encoding")
    public static let contentLanguage = HTTPHeaderField.Name("Content-Language")
    public static let contentLength = HTTPHeaderField.Name("Content-Length")
    public static let contentLocation = HTTPHeaderField.Name("Content-Location")
    public static let contentRange = HTTPHeaderField.Name("Content-Range")
    public static let contentType = HTTPHeaderField.Name("Content-Type")
    public static let date = HTTPHeaderField.Name("Date")
    public static let eTag = HTTPHeaderField.Name("ETag")
    public static let expect = HTTPHeaderField.Name("Expect")
    public static let expires = HTTPHeaderField.Name("Expires")
    public static let from = HTTPHeaderField.Name("From")
    public static let host = HTTPHeaderField.Name("Host")
    public static let ifMatch = HTTPHeaderField.Name("If-Match")
    public static let ifModifiedSince = HTTPHeaderField.Name("If-Modified-Since")
    public static let ifNoneMatch = HTTPHeaderField.Name("If-None-Match")
    public static let ifRange = HTTPHeaderField.Name("If-Range")
    public static let ifUnmodifiedSince = HTTPHeaderField.Name("If-Unmodified-Since")
    public static let lastModified = HTTPHeaderField.Name("Last-Modified")
    public static let location = HTTPHeaderField.Name("Location")
    public static let maxForwards = HTTPHeaderField.Name("Max-Forwards")
    public static let proxyAuthenticate = HTTPHeaderField.Name("Proxy-Authenticate")
    public static let proxyAuthenticationInfo = HTTPHeaderField.Name("Proxy-Authentication-Info")
    public static let proxyAuthorization = HTTPHeaderField.Name("Proxy-Authorization")
    public static let range = HTTPHeaderField.Name("Range")
    public static let referer = HTTPHeaderField.Name("Referer")
    public static let retryAfter = HTTPHeaderField.Name("Retry-After")
    public static let server = HTTPHeaderField.Name("Server")
    public static let te = HTTPHeaderField.Name("TE")
    public static let trailer = HTTPHeaderField.Name("Trailer")
    public static let upgrade = HTTPHeaderField.Name("Upgrade")
    public static let userAgent = HTTPHeaderField.Name("User-Agent")
    public static let vary = HTTPHeaderField.Name("Vary")
    public static let via = HTTPHeaderField.Name("Via")
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
