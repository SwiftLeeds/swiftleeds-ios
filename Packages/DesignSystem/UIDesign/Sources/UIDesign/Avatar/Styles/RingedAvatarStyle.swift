import SwiftUI

/// An avatar style that draws a circle with a ring in one color on its rim.
///
/// The ring is decoration. It repeats the role that the text beside the avatar states, so show
/// the role name beside the avatar. The ring sits inside the avatar's frame, so a ringed avatar
/// takes the same space as one in the default style.
///
/// Set the ring's color with the ``SwiftUI/View/avatarRingPalette(_:)`` modifier.
///
/// ```swift
/// Nameplate(speaker.name, detail: "Speaker") {
///     Avatar(url: speaker.photoURL, size: .xLarge, fallback: .initials(speaker.nameComponents))
/// }
/// .avatarStyle(.ringed)
/// .avatarRingPalette(.blue)
/// ```
///
/// The style rings every avatar it reaches, so inside an ``AvatarGroup`` the count of the rest
/// takes a ring too. Ring a person only where their role name shows.
///
/// Any status sits on the avatar's lower trailing edge, over the ring. The style adds an outline
/// under Increase Contrast, over the ring's outer edge.
///
/// You can also use ``AvatarStyle/ringed`` to construct this style.
public struct RingedAvatarStyle: AvatarStyle {
    /// The palette that colors the ring.
    @Environment(\.avatarRingPalette) private var palette

    /// Creates a ringed avatar style.
    public init() {}

    /// Creates a view that represents the body of an avatar.
    ///
    /// - Parameter configuration: The properties of the avatar.
    /// - Returns: A view that draws the avatar as a circle with a ring on its rim.
    @MainActor
    public func makeBody(configuration: Configuration) -> some View {
        ClippedAvatar(configuration: ringed(configuration), shape: .circle)
    }

    /// Returns the properties of an avatar with a ring drawn over its content.
    ///
    /// - Parameter configuration: The properties of the avatar.
    /// - Returns: The same size and status, with the ring over the content.
    @MainActor
    private func ringed(_ configuration: Configuration) -> Configuration {
        Configuration(
            // The ring sits on the frame-sized clear view, not on the content, so a photo larger
            // than the frame cannot size it.
            content: Color.clear
                .overlay { configuration.content }
                .overlay { Circle().strokeBorder(palette.colors.solid, lineWidth: .ring) },
            size: configuration.size,
            status: configuration.status,
        )
    }
}

extension AvatarStyle where Self == RingedAvatarStyle {
    /// An avatar style that draws a circle with a ring on its rim.
    public static var ringed: RingedAvatarStyle { RingedAvatarStyle() }
}
