import SwiftUI

// The body every built-in avatar style shares: clip it to a shape, then mark it.
struct ClippedAvatar<ClipShape: Shape>: View {
    let configuration: AvatarStyleConfiguration
    let shape: ClipShape

    // The content is an overlay, so it cannot change the avatar's size. A frame alone lets content
    // larger than the frame, such as a symbol at an accessibility text size, spill into the layout.
    var body: some View {
        Color.clear
            .frame(width: diameter, height: diameter)
            .overlay { configuration.content }
            .clipShape(shape)
            .overlay(alignment: .bottomTrailing) { mark }
    }

    // The mark sits over the clip, so the edge it marks stays visible. The tint fills the disc and
    // the symbol is cut out of it: at four millimetres a tinted glyph is too thin to read.
    @ViewBuilder
    private var mark: some View {
        if let status = configuration.status {
            Image(icon: status.icon)
                .resizable()
                .scaledToFit()
                // The symbol draws its own enclosure, so its glyph sits where Apple centered it.
                // Palette gives the glyph the first color and the enclosure the second.
                .symbolRenderingMode(.palette)
                .foregroundStyle(.surface, status.tint)
                .frame(width: discDiameter, height: discDiameter)
                // The ring separates the mark from a photo of any color beneath it. It grows
                // inward, so the whole mark still measures markDiameter and stays off the corner.
                .padding(ringWidth)
                .background(.surface, in: .circle)
                .accessibilityLabel(status.label)
        }
    }

    private var diameter: CGFloat {
        configuration.size
    }

    private var markDiameter: CGFloat {
        diameter * Self.markProportion
    }

    private var ringWidth: CGFloat {
        markDiameter * Self.ringProportion
    }

    private var discDiameter: CGFloat {
        markDiameter - ringWidth * 2
    }

    // At this size the mark's center lands on a circle's edge with no offset, because the corner
    // of the frame sits half a mark beyond it.
    private static var markProportion: CGFloat { 0.28 }

    // Thick enough to read against a photo, thin enough to leave the symbol room.
    private static var ringProportion: CGFloat { 0.08 }
}
