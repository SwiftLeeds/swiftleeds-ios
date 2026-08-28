import Foundation

/// An HTTP response status, compared by its code.
public struct HTTPStatus: Equatable, Hashable, Sendable {
    /// The class of a status, named by its first digit (RFC 9110 section 15).
    ///
    /// A code outside 100...599 is `invalid`: the wire grammar can carry it,
    /// but no class is defined for it.
    public enum Category: Equatable, Hashable, Sendable {
        case informational
        case successful
        case redirection
        case clientError
        case serverError
        case invalid
    }

    public let code: HTTPStatusCode

    public init(code: HTTPStatusCode) {
        self.code = code
    }

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

// Every registered status the IANA registry names through RFCs 9110, 6585,
// 7725, 8297 and 8470. The four codes RFC 9110 marks deprecated, reserved or
// unused (305, 306, 402, 418) are deliberately absent.
extension HTTPStatus {
    public static let `continue` = HTTPStatus(code: 100)
    public static let switchingProtocols = HTTPStatus(code: 101)
    public static let earlyHints = HTTPStatus(code: 103)

    public static let ok = HTTPStatus(code: 200)
    public static let created = HTTPStatus(code: 201)
    public static let accepted = HTTPStatus(code: 202)
    public static let nonAuthoritativeInformation = HTTPStatus(code: 203)
    public static let noContent = HTTPStatus(code: 204)
    public static let resetContent = HTTPStatus(code: 205)
    public static let partialContent = HTTPStatus(code: 206)

    public static let multipleChoices = HTTPStatus(code: 300)
    public static let movedPermanently = HTTPStatus(code: 301)
    public static let found = HTTPStatus(code: 302)
    public static let seeOther = HTTPStatus(code: 303)
    public static let notModified = HTTPStatus(code: 304)
    public static let temporaryRedirect = HTTPStatus(code: 307)
    public static let permanentRedirect = HTTPStatus(code: 308)

    public static let badRequest = HTTPStatus(code: 400)
    public static let unauthorized = HTTPStatus(code: 401)
    public static let forbidden = HTTPStatus(code: 403)
    public static let notFound = HTTPStatus(code: 404)
    public static let methodNotAllowed = HTTPStatus(code: 405)
    public static let notAcceptable = HTTPStatus(code: 406)
    public static let proxyAuthenticationRequired = HTTPStatus(code: 407)
    public static let requestTimeout = HTTPStatus(code: 408)
    public static let conflict = HTTPStatus(code: 409)
    public static let gone = HTTPStatus(code: 410)
    public static let lengthRequired = HTTPStatus(code: 411)
    public static let preconditionFailed = HTTPStatus(code: 412)
    public static let contentTooLarge = HTTPStatus(code: 413)
    public static let uriTooLong = HTTPStatus(code: 414)
    public static let unsupportedMediaType = HTTPStatus(code: 415)
    public static let rangeNotSatisfiable = HTTPStatus(code: 416)
    public static let expectationFailed = HTTPStatus(code: 417)
    public static let misdirectedRequest = HTTPStatus(code: 421)
    public static let unprocessableContent = HTTPStatus(code: 422)
    public static let tooEarly = HTTPStatus(code: 425)
    public static let upgradeRequired = HTTPStatus(code: 426)
    public static let preconditionRequired = HTTPStatus(code: 428)
    public static let tooManyRequests = HTTPStatus(code: 429)
    public static let requestHeaderFieldsTooLarge = HTTPStatus(code: 431)
    public static let unavailableForLegalReasons = HTTPStatus(code: 451)

    public static let internalServerError = HTTPStatus(code: 500)
    public static let notImplemented = HTTPStatus(code: 501)
    public static let badGateway = HTTPStatus(code: 502)
    public static let serviceUnavailable = HTTPStatus(code: 503)
    public static let gatewayTimeout = HTTPStatus(code: 504)
    public static let httpVersionNotSupported = HTTPStatus(code: 505)
    public static let networkAuthenticationRequired = HTTPStatus(code: 511)
}

extension HTTPURLResponse {
    public var status: HTTPStatus {
        HTTPStatus(code: HTTPStatusCode(statusCode))
    }
}

extension String {
    /// Creates the category's stable name for a log field.
    public init(_ category: HTTPStatus.Category) {
        self = switch category {
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
