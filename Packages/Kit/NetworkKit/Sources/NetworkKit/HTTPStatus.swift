import Foundation

/// An HTTP response status, compared by its code.
///
/// Every status RFC 9110, 6585, 7725, 8297 and 8470 register is a constant.
/// The four codes RFC 9110 marks deprecated, reserved or unused (305, 306,
/// 402, 418) are absent.
public struct HTTPStatus: Equatable, Hashable, Sendable {
    /// The class of a status, named by its first digit (RFC 9110 section 15).
    ///
    /// A code outside 100...599 is `invalid`: the wire grammar can carry it,
    /// but no class is defined for it.
    public enum Category: Equatable, Hashable, Sendable {
        /// The 1xx class: the request continues.
        case informational
        /// The 2xx class: the request succeeded.
        case successful
        /// The 3xx class: further action is needed.
        case redirection
        /// The 4xx class: the request is at fault.
        case clientError
        /// The 5xx class: the server failed.
        case serverError
        /// No class: a code outside 100 to 599.
        case invalid
    }

    /// The code.
    public let code: HTTPStatusCode

    /// Creates a status.
    public init(code: HTTPStatusCode) {
        self.code = code
    }

    /// The class of the status.
    public var category: Category {
        switch code {
        // swiftlint:disable no_magic_numbers - RFC 9110 section 15 fixes each class's range
        case 100...199:
            .informational

        case 200...299:
            .successful

        case 300...399:
            .redirection

        case 400...499:
            .clientError

        case 500...599:
            .serverError

        // swiftlint:enable no_magic_numbers
        default:
            .invalid
        }
    }
}

extension HTTPStatus {
    // swiftlint:disable no_magic_numbers - each code is the one its RFC registers
    /// 100 Continue: the client should send the body.
    public static let `continue` = HTTPStatus(code: 100)
    /// 101 Switching Protocols: the server switches to the requested protocol.
    public static let switchingProtocols = HTTPStatus(code: 101)
    /// 103 Early Hints: some headers arrive before the final response.
    public static let earlyHints = HTTPStatus(code: 103)

    /// 200 OK: the request succeeded.
    public static let ok = HTTPStatus(code: 200)
    /// 201 Created: a new resource was created.
    public static let created = HTTPStatus(code: 201)
    /// 202 Accepted: the request was accepted but is not finished.
    public static let accepted = HTTPStatus(code: 202)
    /// 203 Non-Authoritative Information: a proxy changed the response.
    public static let nonAuthoritativeInformation = HTTPStatus(code: 203)
    /// 204 No Content: the request succeeded with no body.
    public static let noContent = HTTPStatus(code: 204)
    /// 205 Reset Content: the client should reset its form.
    public static let resetContent = HTTPStatus(code: 205)
    /// 206 Partial Content: the body is the requested range.
    public static let partialContent = HTTPStatus(code: 206)

    /// 300 Multiple Choices: more than one representation exists.
    public static let multipleChoices = HTTPStatus(code: 300)
    /// 301 Moved Permanently: the resource moved for good.
    public static let movedPermanently = HTTPStatus(code: 301)
    /// 302 Found: the resource is elsewhere for now.
    public static let found = HTTPStatus(code: 302)
    /// 303 See Other: the answer is at another URI, fetched with GET.
    public static let seeOther = HTTPStatus(code: 303)
    /// 304 Not Modified: the cached copy is still current.
    public static let notModified = HTTPStatus(code: 304)
    /// 307 Temporary Redirect: elsewhere for now, with the same method.
    public static let temporaryRedirect = HTTPStatus(code: 307)
    /// 308 Permanent Redirect: moved for good, with the same method.
    public static let permanentRedirect = HTTPStatus(code: 308)

    /// 400 Bad Request: the server cannot read the request.
    public static let badRequest = HTTPStatus(code: 400)
    /// 401 Unauthorized: the request needs valid credentials.
    public static let unauthorized = HTTPStatus(code: 401)
    /// 403 Forbidden: the server refuses the request.
    public static let forbidden = HTTPStatus(code: 403)
    /// 404 Not Found: the resource does not exist.
    public static let notFound = HTTPStatus(code: 404)
    /// 405 Method Not Allowed: the resource does not support the method.
    public static let methodNotAllowed = HTTPStatus(code: 405)
    /// 406 Not Acceptable: no representation matches the Accept headers.
    public static let notAcceptable = HTTPStatus(code: 406)
    /// 407 Proxy Authentication Required: the proxy needs credentials.
    public static let proxyAuthenticationRequired = HTTPStatus(code: 407)
    /// 408 Request Timeout: the server gave up waiting for the request.
    public static let requestTimeout = HTTPStatus(code: 408)
    /// 409 Conflict: the request conflicts with the resource's state.
    public static let conflict = HTTPStatus(code: 409)
    /// 410 Gone: the resource is gone for good.
    public static let gone = HTTPStatus(code: 410)
    /// 411 Length Required: the request needs a Content-Length.
    public static let lengthRequired = HTTPStatus(code: 411)
    /// 412 Precondition Failed: a request condition was not met.
    public static let preconditionFailed = HTTPStatus(code: 412)
    /// 413 Content Too Large: the body is bigger than the server allows.
    public static let contentTooLarge = HTTPStatus(code: 413)
    /// 414 URI Too Long: the URI is longer than the server allows.
    public static let uriTooLong = HTTPStatus(code: 414)
    /// 415 Unsupported Media Type: the body's format is unsupported.
    public static let unsupportedMediaType = HTTPStatus(code: 415)
    /// 416 Range Not Satisfiable: the requested range is outside the resource.
    public static let rangeNotSatisfiable = HTTPStatus(code: 416)
    /// 417 Expectation Failed: the server cannot meet the Expect header.
    public static let expectationFailed = HTTPStatus(code: 417)
    /// 421 Misdirected Request: sent to a server that cannot answer it.
    public static let misdirectedRequest = HTTPStatus(code: 421)
    /// 422 Unprocessable Content: the body is well formed but makes no sense.
    public static let unprocessableContent = HTTPStatus(code: 422)
    /// 425 Too Early: the server will not risk a replayed request.
    public static let tooEarly = HTTPStatus(code: 425)
    /// 426 Upgrade Required: the client must switch protocol.
    public static let upgradeRequired = HTTPStatus(code: 426)
    /// 428 Precondition Required: the request must be conditional.
    public static let preconditionRequired = HTTPStatus(code: 428)
    /// 429 Too Many Requests: the client sent too many requests.
    public static let tooManyRequests = HTTPStatus(code: 429)
    /// 431 Request Header Fields Too Large: the headers are too big.
    public static let requestHeaderFieldsTooLarge = HTTPStatus(code: 431)
    /// 451 Unavailable For Legal Reasons: a legal demand blocks the resource.
    public static let unavailableForLegalReasons = HTTPStatus(code: 451)

    /// 500 Internal Server Error: the server hit an unexpected error.
    public static let internalServerError = HTTPStatus(code: 500)
    /// 501 Not Implemented: the server does not support the method.
    public static let notImplemented = HTTPStatus(code: 501)
    /// 502 Bad Gateway: an upstream server sent a bad response.
    public static let badGateway = HTTPStatus(code: 502)
    /// 503 Service Unavailable: the server is overloaded or in maintenance.
    public static let serviceUnavailable = HTTPStatus(code: 503)
    /// 504 Gateway Timeout: an upstream server did not answer in time.
    public static let gatewayTimeout = HTTPStatus(code: 504)
    /// 505 HTTP Version Not Supported: the HTTP version is unsupported.
    public static let httpVersionNotSupported = HTTPStatus(code: 505)
    /// 511 Network Authentication Required: the network needs a sign-in.
    public static let networkAuthenticationRequired = HTTPStatus(code: 511)
    // swiftlint:enable no_magic_numbers
}

extension HTTPURLResponse {
    /// The response's status.
    public var status: HTTPStatus {
        HTTPStatus(code: HTTPStatusCode(statusCode))
    }
}

extension String {
    /// Creates the category's stable name for a log field.
    /// - Parameter category: The category to name.
    public init(_ category: HTTPStatus.Category) {
        self =
            switch category {
            case .informational:
                "informational"

            case .successful:
                "successful"

            case .redirection:
                "redirection"

            case .clientError:
                "clientError"

            case .serverError:
                "serverError"

            case .invalid:
                "invalid"
            }
    }
}
