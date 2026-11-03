import SwiftUI

/// An avatar clipped to a shape and outlined, with any status over the outline.
///
/// The built-in avatar styles share this layout.
struct ClippedAvatar<ClipShape: InsettableShape>: View {
    /// The properties of the avatar.
    let configuration: AvatarStyleConfiguration

    /// The shape to clip and outline the avatar with.
    let shape: ClipShape

    /// The furthest, in points, the status's center sits in from the bottom and trailing edges.
    ///
    /// With no limit, the status's center sits its own radius in, so the mark touches both edges.
    var statusInsetLimit: CGFloat = .infinity

    var body: some View {
        let limit = statusInsetLimit
        Color.clear
            .frame(avatarSize: configuration.size)
            // An overlay, so content larger than the frame cannot grow the avatar.
            .overlay { configuration.content }
            .clipShape(shape)
            .overlay { shape.strokeBorder(.border, lineWidth: .edge) }
            // Over the clip and the outline, so neither cuts the status. The guides inset the
            // status's center from each edge by its own radius, or by `statusInsetLimit` if that
            // is smaller.
            .overlay(alignment: .bottomTrailing) {
                configuration.status
                    .alignmentGuide(.trailing) {
                        $0[HorizontalAlignment.center] + min(limit, $0[HorizontalAlignment.center])
                    }
                    .alignmentGuide(.bottom) {
                        $0[VerticalAlignment.center] + min(limit, $0[VerticalAlignment.center])
                    }
            }
    }
}
