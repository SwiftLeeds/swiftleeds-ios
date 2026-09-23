import SwiftUI

extension EnvironmentValues {
    // The diameter the avatar around this view draws at, after the text size has scaled it.
    // A built-in fallback sizes its mark from it, because a mark that follows the text size
    // instead overflows a small avatar.
    @Entry var avatarDiameter: AvatarSize = .medium
}
