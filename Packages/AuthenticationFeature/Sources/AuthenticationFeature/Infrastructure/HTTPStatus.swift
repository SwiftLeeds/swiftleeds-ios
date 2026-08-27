import Foundation

/// An HTTP response status, compared by its code.
package struct HTTPStatus: Equatable, Hashable, Sendable {
    /// The class of a status, named by its first digit (RFC 9110 section 15).
    ///
    /// A code outside 100...599 is `invalid`: the wire grammar can carry it,
    /// but no class is defined for it.
    package enum Category: Equatable, Hashable, Sendable {
        case informational
        case successful
        case redirection
        case clientError
        case serverError
        case invalid
    }

    package let code: HTTPStatusCode

    package init(code: HTTPStatusCode) {
        self.code = code
    }

    package var category: Category {
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
    package static let `continue` = HTTPStatus(code: 100)
    package static let switchingProtocols = HTTPStatus(code: 101)
    package static let earlyHints = HTTPStatus(code: 103)

    package static let ok = HTTPStatus(code: 200)
    package static let created = HTTPStatus(code: 201)
    package static let accepted = HTTPStatus(code: 202)
    package static let nonAuthoritativeInformation = HTTPStatus(code: 203)
    package static let noContent = HTTPStatus(code: 204)
    package static let resetContent = HTTPStatus(code: 205)
    package static let partialContent = HTTPStatus(code: 206)

    package static let multipleChoices = HTTPStatus(code: 300)
    package static let movedPermanently = HTTPStatus(code: 301)
    package static let found = HTTPStatus(code: 302)
    package static let seeOther = HTTPStatus(code: 303)
    package static let notModified = HTTPStatus(code: 304)
    package static let temporaryRedirect = HTTPStatus(code: 307)
    package static let permanentRedirect = HTTPStatus(code: 308)

    package static let badRequest = HTTPStatus(code: 400)
    package static let unauthorized = HTTPStatus(code: 401)
    package static let forbidden = HTTPStatus(code: 403)
    package static let notFound = HTTPStatus(code: 404)
    package static let methodNotAllowed = HTTPStatus(code: 405)
    package static let notAcceptable = HTTPStatus(code: 406)
    package static let proxyAuthenticationRequired = HTTPStatus(code: 407)
    package static let requestTimeout = HTTPStatus(code: 408)
    package static let conflict = HTTPStatus(code: 409)
    package static let gone = HTTPStatus(code: 410)
    package static let lengthRequired = HTTPStatus(code: 411)
    package static let preconditionFailed = HTTPStatus(code: 412)
    package static let contentTooLarge = HTTPStatus(code: 413)
    package static let uriTooLong = HTTPStatus(code: 414)
    package static let unsupportedMediaType = HTTPStatus(code: 415)
    package static let rangeNotSatisfiable = HTTPStatus(code: 416)
    package static let expectationFailed = HTTPStatus(code: 417)
    package static let misdirectedRequest = HTTPStatus(code: 421)
    package static let unprocessableContent = HTTPStatus(code: 422)
    package static let tooEarly = HTTPStatus(code: 425)
    package static let upgradeRequired = HTTPStatus(code: 426)
    package static let preconditionRequired = HTTPStatus(code: 428)
    package static let tooManyRequests = HTTPStatus(code: 429)
    package static let requestHeaderFieldsTooLarge = HTTPStatus(code: 431)
    package static let unavailableForLegalReasons = HTTPStatus(code: 451)

    package static let internalServerError = HTTPStatus(code: 500)
    package static let notImplemented = HTTPStatus(code: 501)
    package static let badGateway = HTTPStatus(code: 502)
    package static let serviceUnavailable = HTTPStatus(code: 503)
    package static let gatewayTimeout = HTTPStatus(code: 504)
    package static let httpVersionNotSupported = HTTPStatus(code: 505)
    package static let networkAuthenticationRequired = HTTPStatus(code: 511)
}

extension HTTPURLResponse {
    package var status: HTTPStatus {
        HTTPStatus(code: HTTPStatusCode(statusCode))
    }
}

extension String {
    /// Creates the category's stable name for a log field.
    package init(_ category: HTTPStatus.Category) {
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
