import SwiftUI

/// An avatar style that draws a circle with a ring in one color on its rim.
///
/// The ring is decoration. It repeats the role that the text beside the avatar states, so show
/// the role name beside the avatar, as ``Nameplate`` does. The ring sits inside the avatar's
/// frame, so a ringed avatar takes the same space as one in the default style.
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
/// Inside an ``AvatarGroup``, every avatar and the count of the rest take the ring. Ring a person
/// only where their role name shows.
///
/// Any status sits on the avatar's lower trailing edge, over the ring. It adds an outline under
/// Increase Contrast.
///
/// You can also use ``AvatarStyle/ringed`` to construct this style.
public struct RingedAvatarStyle: AvatarStyle {
    /// The palette that colors the ring.
    @Environment(\.avatarRingPalette) private var palette

    /// Creates a ringed avatar style.
    public init() {}

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
