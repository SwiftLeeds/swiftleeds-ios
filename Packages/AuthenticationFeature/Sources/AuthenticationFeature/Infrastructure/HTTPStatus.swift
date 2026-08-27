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

extension HTTPStatus {
    package static let ok = HTTPStatus(200)
    package static let unauthorized = HTTPStatus(401)
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
