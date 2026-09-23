import SwiftUI

// The body every built-in avatar style shares: clip it to a shape, then place the status.
struct ClippedAvatar<ClipShape: Shape>: View {
    let configuration: AvatarStyleConfiguration
    let shape: ClipShape

    // The content is an overlay, so it cannot change the avatar's size. A frame alone lets content
    // larger than the frame, such as a symbol at an accessibility text size, spill into the layout.
    var body: some View {
        Color.clear
            .frame(width: configuration.size, height: configuration.size)
            .overlay { configuration.content }
            .clipShape(shape)
            // Over the clip, so the edge the status marks stays visible.
            .overlay(alignment: .bottomTrailing) { configuration.status }
    }
}
