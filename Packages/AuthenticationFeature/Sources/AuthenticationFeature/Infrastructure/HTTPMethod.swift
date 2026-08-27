/// An HTTP request method, carried on the wire as its uppercase raw value.
///
/// Methods are case-sensitive (RFC 9110 section 9.1).
package enum HTTPMethod: String, Equatable, Hashable, Sendable {
    // Every method RFC 9110 section 9 registers, plus PATCH (RFC 5789).
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case connect = "CONNECT"
    case options = "OPTIONS"
    case trace = "TRACE"
    case patch = "PATCH"
}
