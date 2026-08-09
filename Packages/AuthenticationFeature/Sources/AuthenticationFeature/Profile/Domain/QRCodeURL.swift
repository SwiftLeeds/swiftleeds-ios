import Foundation

package struct QRCodeURL: Equatable, Hashable, Sendable {
    private let storage: URL

    package init(_ value: URL) {
        self.storage = value
    }

    fileprivate var urlValue: URL { storage }
}

extension URL {
    package init(_ qrCodeURL: QRCodeURL) {
        self = qrCodeURL.urlValue
    }
}
