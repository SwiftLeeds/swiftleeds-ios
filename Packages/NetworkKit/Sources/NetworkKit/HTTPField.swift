import Foundation

/// One HTTP header, as a name and value pair.
public struct HTTPField: Equatable, Hashable, Sendable {
    /// A header name. Case-insensitive, so `Accept` and `accept` are one name.
    ///
    /// `String(name)` gives back the casing you wrote.
    public struct Name: Equatable, Hashable, Sendable {
        fileprivate let value: String

        /// Creates a header name for one the constants below do not cover.
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

    /// A header value. Sent exactly as written, and case-sensitive.
    public struct Value: Equatable, Hashable, Sendable {
        fileprivate let value: String

        /// Creates a header value.
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

// Every header RFC 9110 and RFC 9111 define. Anything else, including CORS,
// cookies and WebSocket: `HTTPField.Name("X-Whatever")`.
extension HTTPField.Name {
    public static let accept = HTTPField.Name("Accept")
    public static let acceptEncoding = HTTPField.Name("Accept-Encoding")
    public static let acceptLanguage = HTTPField.Name("Accept-Language")
    public static let acceptRanges = HTTPField.Name("Accept-Ranges")
    public static let age = HTTPField.Name("Age")
    public static let allow = HTTPField.Name("Allow")
    public static let authenticationInfo = HTTPField.Name("Authentication-Info")
    public static let authorization = HTTPField.Name("Authorization")
    public static let cacheControl = HTTPField.Name("Cache-Control")
    public static let connection = HTTPField.Name("Connection")
    public static let contentEncoding = HTTPField.Name("Content-Encoding")
    public static let contentLanguage = HTTPField.Name("Content-Language")
    public static let contentLength = HTTPField.Name("Content-Length")
    public static let contentLocation = HTTPField.Name("Content-Location")
    public static let contentRange = HTTPField.Name("Content-Range")
    public static let contentType = HTTPField.Name("Content-Type")
    public static let date = HTTPField.Name("Date")
    public static let eTag = HTTPField.Name("ETag")
    public static let expect = HTTPField.Name("Expect")
    public static let expires = HTTPField.Name("Expires")
    public static let from = HTTPField.Name("From")
    public static let host = HTTPField.Name("Host")
    public static let ifMatch = HTTPField.Name("If-Match")
    public static let ifModifiedSince = HTTPField.Name("If-Modified-Since")
    public static let ifNoneMatch = HTTPField.Name("If-None-Match")
    public static let ifRange = HTTPField.Name("If-Range")
    public static let ifUnmodifiedSince = HTTPField.Name("If-Unmodified-Since")
    public static let lastModified = HTTPField.Name("Last-Modified")
    public static let location = HTTPField.Name("Location")
    public static let maxForwards = HTTPField.Name("Max-Forwards")
    public static let proxyAuthenticate = HTTPField.Name("Proxy-Authenticate")
    public static let proxyAuthenticationInfo = HTTPField.Name("Proxy-Authentication-Info")
    public static let proxyAuthorization = HTTPField.Name("Proxy-Authorization")
    public static let range = HTTPField.Name("Range")
    public static let referer = HTTPField.Name("Referer")
    public static let retryAfter = HTTPField.Name("Retry-After")
    public static let server = HTTPField.Name("Server")
    public static let te = HTTPField.Name("TE")
    public static let trailer = HTTPField.Name("Trailer")
    public static let upgrade = HTTPField.Name("Upgrade")
    public static let userAgent = HTTPField.Name("User-Agent")
    public static let vary = HTTPField.Name("Vary")
    public static let via = HTTPField.Name("Via")
    public static let wwwAuthenticate = HTTPField.Name("WWW-Authenticate")
}

extension HTTPField.Value: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension String {
    /// Creates the header name's spelling, with the casing it was given.
    ///
    /// - Parameter name: The name to read.
    public init(_ name: HTTPField.Name) {
        self = name.value
    }

    /// Creates the header value's text.
    ///
    /// - Parameter value: The value to read.
    public init(_ value: HTTPField.Value) {
        self = value.value
    }
}
