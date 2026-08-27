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

    fileprivate let code: Int

    package init(_ code: Int) {
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
    package static let `continue` = HTTPStatus(100)
    package static let switchingProtocols = HTTPStatus(101)
    package static let earlyHints = HTTPStatus(103)

    package static let ok = HTTPStatus(200)
    package static let created = HTTPStatus(201)
    package static let accepted = HTTPStatus(202)
    package static let nonAuthoritativeInformation = HTTPStatus(203)
    package static let noContent = HTTPStatus(204)
    package static let resetContent = HTTPStatus(205)
    package static let partialContent = HTTPStatus(206)

    package static let multipleChoices = HTTPStatus(300)
    package static let movedPermanently = HTTPStatus(301)
    package static let found = HTTPStatus(302)
    package static let seeOther = HTTPStatus(303)
    package static let notModified = HTTPStatus(304)
    package static let temporaryRedirect = HTTPStatus(307)
    package static let permanentRedirect = HTTPStatus(308)

    package static let badRequest = HTTPStatus(400)
    package static let unauthorized = HTTPStatus(401)
    package static let forbidden = HTTPStatus(403)
    package static let notFound = HTTPStatus(404)
    package static let methodNotAllowed = HTTPStatus(405)
    package static let notAcceptable = HTTPStatus(406)
    package static let proxyAuthenticationRequired = HTTPStatus(407)
    package static let requestTimeout = HTTPStatus(408)
    package static let conflict = HTTPStatus(409)
    package static let gone = HTTPStatus(410)
    package static let lengthRequired = HTTPStatus(411)
    package static let preconditionFailed = HTTPStatus(412)
    package static let contentTooLarge = HTTPStatus(413)
    package static let uriTooLong = HTTPStatus(414)
    package static let unsupportedMediaType = HTTPStatus(415)
    package static let rangeNotSatisfiable = HTTPStatus(416)
    package static let expectationFailed = HTTPStatus(417)
    package static let misdirectedRequest = HTTPStatus(421)
    package static let unprocessableContent = HTTPStatus(422)
    package static let tooEarly = HTTPStatus(425)
    package static let upgradeRequired = HTTPStatus(426)
    package static let preconditionRequired = HTTPStatus(428)
    package static let tooManyRequests = HTTPStatus(429)
    package static let requestHeaderFieldsTooLarge = HTTPStatus(431)
    package static let unavailableForLegalReasons = HTTPStatus(451)

    package static let internalServerError = HTTPStatus(500)
    package static let notImplemented = HTTPStatus(501)
    package static let badGateway = HTTPStatus(502)
    package static let serviceUnavailable = HTTPStatus(503)
    package static let gatewayTimeout = HTTPStatus(504)
    package static let httpVersionNotSupported = HTTPStatus(505)
    package static let networkAuthenticationRequired = HTTPStatus(511)
}

extension Int {
    package init(_ status: HTTPStatus) {
        self = status.code
    }
}

extension HTTPURLResponse {
    package var status: HTTPStatus {
        HTTPStatus(statusCode)
    }
}
