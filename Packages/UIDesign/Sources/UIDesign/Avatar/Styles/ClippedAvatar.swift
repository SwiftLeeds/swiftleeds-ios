import SwiftUI

// The body every built-in avatar style shares: size it, then clip it to a shape.
struct ClippedAvatar<ClipShape: Shape>: View {
    // The base size differs per avatar, so the metric scales 1 and multiplies.
    @ScaledMetric(relativeTo: .body) private var textScale: CGFloat = 1

    let configuration: AvatarStyleConfiguration
    let shape: ClipShape

    // The content is an overlay, so it cannot change the avatar's size. A frame alone lets content
    // larger than the frame, such as a symbol at an accessibility text size, spill into the layout.
    var body: some View {
        Color.clear
            .frame(width: diameter, height: diameter)
            .overlay { configuration.content }
            .clipShape(shape)
            .environment(\.avatarDiameter, diameter)
    }

    private var diameter: CGFloat {
        configuration.size * min(textScale, Self.largestGrowth)
    }

    // Past this an avatar crowds the text beside it out of the row.
    private static var largestGrowth: CGFloat { 1.75 }
}
