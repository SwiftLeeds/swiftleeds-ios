import SwiftUI

/// An avatar clipped to a shape, with any status over the clipped edge.
///
/// The built-in avatar styles share this layout, so they differ only in the
/// shape they pass.
struct ClippedAvatar<ClipShape: Shape>: View {
    /// The properties of the avatar.
    let configuration: AvatarStyleConfiguration

    /// The shape to clip the avatar to.
    let shape: ClipShape

    var body: some View {
        Color.clear
            .frame(configuration.size)
            // An overlay, so content larger than the frame cannot grow the avatar.
            .overlay { configuration.content }
            .clipShape(shape)
            // Over the clip, so the edge the status marks stays visible.
            .overlay(alignment: .bottomTrailing) { configuration.status }
    }
}
