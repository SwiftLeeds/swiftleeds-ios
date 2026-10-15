import SwiftUI

/// A view that marks an avatar with the state of the person it shows.
///
/// The component draws it, so every style shows the same mark.
struct AvatarStatusMark: View {
    /// The state to show.
    let status: AvatarStatus

    /// The diameter of the avatar this marks, which sets the mark's own size.
    let avatarDiameter: AvatarSize

    var body: some View {
        Image(icon: status.icon)
            .resizable()
            .scaledToFit()
            // The glyph takes the first color, the symbol's own enclosure the second.
            .symbolRenderingMode(.palette)
            .foregroundStyle(.surface, status.tint)
            .frame(width: discDiameter, height: discDiameter)
            // The ring grows inward, so the whole mark still measures diameter.
            .padding(ringWidth)
            .background(.surface, in: .circle)
            .accessibilityLabel(status.label)
    }

    /// The width of the whole mark, including its ring.
    private var diameter: CGFloat {
        CGFloat(avatarDiameter) * Self.proportion
    }

    /// The width of the ring separating the mark from what is behind it.
    private var ringWidth: CGFloat {
        diameter * Self.ringProportion
    }

    /// The width of the symbol inside the ring.
    private var discDiameter: CGFloat {
        diameter - ringWidth * 2
    }

    /// How much of the avatar's diameter the mark covers.
    ///
    /// At this size the mark's center lands on a circle's edge with no offset,
    /// because the corner of the avatar's frame sits half a mark beyond it.
    private static var proportion: CGFloat { 0.28 }

    /// How much of the mark's diameter the ring takes.
    ///
    /// Thick enough to read against a photo, thin enough to leave the symbol
    /// room.
    private static var ringProportion: CGFloat { 0.08 }
}
