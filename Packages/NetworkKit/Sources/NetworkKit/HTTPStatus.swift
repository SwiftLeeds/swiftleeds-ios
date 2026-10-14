import Foundation

/// An HTTP response status, compared by its code.
///
/// Every registered status the IANA registry names is a constant. The four
/// codes RFC 9110 marks deprecated, reserved or unused (305, 306, 402, 418)
/// are absent.
public struct HTTPStatus: Equatable, Hashable, Sendable {
    /// The class of a status, named by its first digit (RFC 9110 section 15).
    ///
    /// A code outside 100...599 is `invalid`: the wire grammar can carry it,
    /// but no class is defined for it.
    public enum Category: Equatable, Hashable, Sendable {
        /// 1xx, the request continues.
        case informational
        /// 2xx, the request succeeded.
        case successful
        /// 3xx, further action is needed.
        case redirection
        /// 4xx, the request is at fault.
        case clientError
        /// 5xx, the server failed.
        case serverError
        /// A code outside 100 to 599.
        case invalid
    }

    /// The three-digit code.
    public let code: HTTPStatusCode

    /// Creates a status.
    public init(code: HTTPStatusCode) {
        self.code = code
    }

    /// The class of the status, by its first digit.
    public var category: Category {
        switch code {
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
        default:
            .invalid
        }
    }
}

extension HTTPStatus {
    /// 100, the client should send the body.
    public static let `continue` = HTTPStatus(code: 100)
    /// 101, the server is switching to the requested protocol.
    public static let switchingProtocols = HTTPStatus(code: 101)
    /// 103, some headers arrive before the final response.
    public static let earlyHints = HTTPStatus(code: 103)

    /// 200, the request succeeded.
    public static let ok = HTTPStatus(code: 200)
    /// 201, a new resource was created.
    public static let created = HTTPStatus(code: 201)
    /// 202, the request was accepted but is not finished.
    public static let accepted = HTTPStatus(code: 202)
    /// 203, a proxy changed the response.
    public static let nonAuthoritativeInformation = HTTPStatus(code: 203)
    /// 204, the request succeeded with no body.
    public static let noContent = HTTPStatus(code: 204)
    /// 205, the client should reset the view that sent the request.
    public static let resetContent = HTTPStatus(code: 205)
    /// 206, the body is the requested range.
    public static let partialContent = HTTPStatus(code: 206)

    /// 300, more than one representation exists.
    public static let multipleChoices = HTTPStatus(code: 300)
    /// 301, the resource moved for good.
    public static let movedPermanently = HTTPStatus(code: 301)
    /// 302, the resource is elsewhere for now.
    public static let found = HTTPStatus(code: 302)
    /// 303, the answer is at another URI, fetched with GET.
    public static let seeOther = HTTPStatus(code: 303)
    /// 304, the cached copy is still current.
    public static let notModified = HTTPStatus(code: 304)
    /// 307, the resource is elsewhere for now, same method.
    public static let temporaryRedirect = HTTPStatus(code: 307)
    /// 308, the resource moved for good, same method.
    public static let permanentRedirect = HTTPStatus(code: 308)

    /// 400, the server cannot read the request.
    public static let badRequest = HTTPStatus(code: 400)
    /// 401, the request needs valid credentials.
    public static let unauthorized = HTTPStatus(code: 401)
    /// 403, the server refuses the request.
    public static let forbidden = HTTPStatus(code: 403)
    /// 404, the resource does not exist.
    public static let notFound = HTTPStatus(code: 404)
    /// 405, the resource does not support the method.
    public static let methodNotAllowed = HTTPStatus(code: 405)
    /// 406, no representation matches the Accept headers.
    public static let notAcceptable = HTTPStatus(code: 406)
    /// 407, the proxy needs credentials.
    public static let proxyAuthenticationRequired = HTTPStatus(code: 407)
    /// 408, the server gave up waiting for the request.
    public static let requestTimeout = HTTPStatus(code: 408)
    /// 409, the request conflicts with the resource's state.
    public static let conflict = HTTPStatus(code: 409)
    /// 410, the resource is gone for good.
    public static let gone = HTTPStatus(code: 410)
    /// 411, the request needs a Content-Length.
    public static let lengthRequired = HTTPStatus(code: 411)
    /// 412, a request condition was not met.
    public static let preconditionFailed = HTTPStatus(code: 412)
    /// 413, the body is bigger than the server allows.
    public static let contentTooLarge = HTTPStatus(code: 413)
    /// 414, the URI is longer than the server allows.
    public static let uriTooLong = HTTPStatus(code: 414)
    /// 415, the server cannot handle the body's format.
    public static let unsupportedMediaType = HTTPStatus(code: 415)
    /// 416, the requested range is outside the resource.
    public static let rangeNotSatisfiable = HTTPStatus(code: 416)
    /// 417, the server cannot meet the Expect header.
    public static let expectationFailed = HTTPStatus(code: 417)
    /// 421, the request reached a server that cannot answer it.
    public static let misdirectedRequest = HTTPStatus(code: 421)
    /// 422, the body is well formed but makes no sense.
    public static let unprocessableContent = HTTPStatus(code: 422)
    /// 425, the server will not risk a replayed request.
    public static let tooEarly = HTTPStatus(code: 425)
    /// 426, the client must switch protocol.
    public static let upgradeRequired = HTTPStatus(code: 426)
    /// 428, the request must be conditional.
    public static let preconditionRequired = HTTPStatus(code: 428)
    /// 429, the client sent too many requests.
    public static let tooManyRequests = HTTPStatus(code: 429)
    /// 431, the headers are bigger than the server allows.
    public static let requestHeaderFieldsTooLarge = HTTPStatus(code: 431)
    /// 451, a legal demand blocks the resource.
    public static let unavailableForLegalReasons = HTTPStatus(code: 451)

    /// 500, the server hit an unexpected error.
    public static let internalServerError = HTTPStatus(code: 500)
    /// 501, the server does not support the method.
    public static let notImplemented = HTTPStatus(code: 501)
    /// 502, an upstream server sent a bad response.
    public static let badGateway = HTTPStatus(code: 502)
    /// 503, the server is overloaded or down for maintenance.
    public static let serviceUnavailable = HTTPStatus(code: 503)
    /// 504, an upstream server did not answer in time.
    public static let gatewayTimeout = HTTPStatus(code: 504)
    /// 505, the server does not support the HTTP version.
    public static let httpVersionNotSupported = HTTPStatus(code: 505)
    /// 511, the network needs the client to sign in.
    public static let networkAuthenticationRequired = HTTPStatus(code: 511)
}

extension HTTPURLResponse {
    /// The response's status.
    public var status: HTTPStatus {
        HTTPStatus(code: HTTPStatusCode(statusCode))
    }
}

extension String {
    /// Creates the category's stable name for a log field.
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
