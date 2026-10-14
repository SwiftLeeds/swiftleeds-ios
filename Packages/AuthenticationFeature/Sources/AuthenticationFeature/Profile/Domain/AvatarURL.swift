import Foundation

/// The address of an attendee's avatar image.
package struct AvatarURL: Equatable, Hashable, Sendable {
    /// The address of the avatar image.
    fileprivate let storage: URL

    /// Creates an avatar address, accepting any URL.
    /// - Parameter value: The address of the avatar image.
    package init(_ value: URL) {
        self.storage = value
    }
}

extension URL {
    /// Creates a URL from an avatar address.
    /// - Parameter avatarURL: The avatar address to convert.
    package init(_ avatarURL: AvatarURL) {
        self = avatarURL.storage
    }
}
