import SwiftUI

/// The default avatar group style.
///
/// It draws the avatars side by side, a small gap apart, with any count after
/// them.
///
/// You can also use ``AvatarGroupStyle/automatic`` to construct this style.
public struct DefaultAvatarGroupStyle: AvatarGroupStyle {
    /// Creates a default avatar group style.
    public init() {}

    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: .xxs) {
            configuration.content
            configuration.overflow
        }
    }
}

extension AvatarGroupStyle where Self == DefaultAvatarGroupStyle {
    /// The default avatar group style.
    public static var automatic: DefaultAvatarGroupStyle { DefaultAvatarGroupStyle() }
}
