import SwiftUI

extension EnvironmentValues {
    /// The artwork style applied to the view hierarchy.
    @Entry public var artworkStyle: any ArtworkStyle = .automatic
}

extension View {
    /// Sets the style for artworks within this view.
    ///
    /// ```swift
    /// VStack {
    ///     Artwork(icon: Icon(.hammerFill), palette: .teal)
    /// }
    /// .artworkStyle(.automatic)
    /// ```
    ///
    /// - Parameter style: The artwork style to apply.
    /// - Returns: A view that uses the given style for the artworks within it.
    public func artworkStyle(_ style: some ArtworkStyle) -> some View {
        environment(\.artworkStyle, style)
    }
}
