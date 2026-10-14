import Foundation

package struct AvatarURL: Equatable, Hashable, Sendable {
    /// The address of the avatar image.
    fileprivate let storage: URL

    package init(_ value: URL) {
        self.storage = value
    }
}

extension URL {
    package init(_ avatarURL: AvatarURL) {
        self = avatarURL.storage
    }
}
