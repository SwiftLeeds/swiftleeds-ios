import Foundation

/// An HTTP response status, compared by its code.
package struct HTTPStatus: Equatable, Hashable, Sendable {
    private let code: Int

    package init(_ code: Int) {
        self.code = code
    }

    fileprivate var intValue: Int { code }
}

extension HTTPStatus {
    package static let ok = HTTPStatus(200)
    package static let unauthorized = HTTPStatus(401)
}

extension Int {
    package init(_ status: HTTPStatus) {
        self = status.intValue
    }
}

extension HTTPURLResponse {
    package var status: HTTPStatus {
        HTTPStatus(statusCode)
    }
}
