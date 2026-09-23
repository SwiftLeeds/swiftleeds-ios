import SwiftUI

// How a status looks. The component draws it, so every style shows the same mark and chooses
// only where it goes.
struct AvatarStatusMark: View {
    let status: AvatarStatus
    let avatarDiameter: CGFloat

    var body: some View {
        Image(icon: status.icon)
            .resizable()
            .scaledToFit()
            // The symbol draws its own enclosure, so its glyph sits where Apple centered it.
            // Palette gives the glyph the first color and the enclosure the second.
            .symbolRenderingMode(.palette)
            .foregroundStyle(.surface, status.tint)
            .frame(width: discDiameter, height: discDiameter)
            // The ring separates the mark from a photo of any color beneath it. It grows inward,
            // so the whole mark still measures diameter and stays off the shape's corner.
            .padding(ringWidth)
            .background(.surface, in: .circle)
            .accessibilityLabel(status.label)
    }

    private var diameter: CGFloat {
        avatarDiameter * Self.proportion
    }

    private var ringWidth: CGFloat {
        diameter * Self.ringProportion
    }

    private var discDiameter: CGFloat {
        diameter - ringWidth * 2
    }

    // At this size the mark's center lands on a circle's edge with no offset, because the corner
    // of the avatar's frame sits half a mark beyond it.
    private static var proportion: CGFloat { 0.28 }

    // Thick enough to read against a photo, thin enough to leave the symbol room.
    private static var ringProportion: CGFloat { 0.08 }
}
