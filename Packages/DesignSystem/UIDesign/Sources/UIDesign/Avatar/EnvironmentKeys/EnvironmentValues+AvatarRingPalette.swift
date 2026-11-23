import SwiftUI

extension EnvironmentValues {
    /// The palette applied to the avatar rings in the view hierarchy.
    ///
    /// The default is ``AvatarRingPalette/neutral``.
    @Entry public var avatarRingPalette: AvatarRingPalette = .neutral
}

extension View {
    /// Sets the palette for avatar rings within this view.
    ///
    /// ```swift
    /// Avatar(url: speaker.photoURL, size: .large)
    ///     .avatarStyle(.ringed)
    ///     .avatarRingPalette(.blue)
    /// ```
    ///
    /// - Parameter palette: The palette to apply.
    /// - Returns: A view that uses the given palette for the avatar rings within it.
    public func avatarRingPalette(_ palette: AvatarRingPalette) -> some View {
        environment(\.avatarRingPalette, palette)
    }
}
