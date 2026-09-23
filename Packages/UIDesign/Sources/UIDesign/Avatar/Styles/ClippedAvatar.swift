import SwiftUI

/// The body the built-in avatar styles share.
struct ClippedAvatar<ClipShape: Shape>: View {
    let configuration: AvatarStyleConfiguration
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
