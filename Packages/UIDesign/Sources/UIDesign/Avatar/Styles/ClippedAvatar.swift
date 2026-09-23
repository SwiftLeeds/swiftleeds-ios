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

    // The mark sits over the clip, so the edge it marks stays visible. The tint is the symbol,
    // never a fill behind it, so a status reads the same here as it does anywhere else.
    @ViewBuilder
    private var mark: some View {
        if let status = configuration.status {
            Image(icon: status.icon)
                .font(.system(size: markDiameter * Self.symbolProportion))
                .foregroundStyle(status.tint)
                // A fixed box, so a wide symbol such as a triangle marks the same spot at the
                // same size as a narrow one. The disc separates the mark from the photo beneath.
                .frame(width: markDiameter, height: markDiameter)
                .background(Circle().fill(.surface))
                .accessibilityLabel(status.label)
        }
    }

    private var diameter: CGFloat {
        configuration.size
    }

    private var markDiameter: CGFloat {
        diameter * Self.markProportion
    }

    // At this size the mark's center lands on a circle's edge with no offset, because the corner
    // of the frame sits half a mark beyond it.
    private static var markProportion: CGFloat { 0.28 }

    // Leaves a rim of the disc around the symbol.
    private static var symbolProportion: CGFloat { 0.8 }
}
