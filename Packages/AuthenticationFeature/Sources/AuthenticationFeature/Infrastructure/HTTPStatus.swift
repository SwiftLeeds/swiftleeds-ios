/// An HTTP response status, compared by its code.
package struct HTTPStatus: Equatable, Hashable, Sendable {
    fileprivate let code: Int

    package init(_ code: Int) {
        self.code = code
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
