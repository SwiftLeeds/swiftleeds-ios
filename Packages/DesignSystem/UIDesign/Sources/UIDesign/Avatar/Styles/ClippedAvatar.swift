import SwiftUI

/// An avatar clipped to a shape, with any status over the clipped edge.
///
/// The built-in avatar styles share this layout.
struct ClippedAvatar<ClipShape: Shape>: View {
    /// The properties of the avatar.
    let configuration: AvatarStyleConfiguration

    /// The shape to clip the avatar to.
    let shape: ClipShape

    /// The furthest, in points, the status's center sits in from the bottom and trailing edges.
    ///
    /// With no limit, the status's center sits its own radius in, so the mark touches both edges.
    var statusInsetLimit: CGFloat = .infinity

    var body: some View {
        let limit = statusInsetLimit
        Color.clear
            .frame(configuration.size)
            // An overlay, so content larger than the frame cannot grow the avatar.
            .overlay { configuration.content }
            .clipShape(shape)
            // Over the clip, so the edge the status marks stays visible. The guides inset the status's
            // center from each edge by its own radius, or by `statusInsetLimit` if that is smaller.
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
