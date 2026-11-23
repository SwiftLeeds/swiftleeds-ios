import SwiftUI

/// A type that applies a custom appearance to all artworks within a view hierarchy.
///
/// To configure the current artwork style for a view hierarchy, use the
/// ``SwiftUI/View/artworkStyle(_:)`` modifier.
///
/// ```swift
/// struct OutlineArtworkStyle: ArtworkStyle {
///     func makeBody(configuration: Configuration) -> some View {
///         configuration.symbol
///             .padding()
///             .foregroundStyle(.secondary)
///     }
/// }
/// ```
///
/// The symbol is hidden from VoiceOver. Text that a style adds is read.
///
/// To draw an artwork whose item is still loading, read `redactionReasons` from the environment.
///
/// A style may read the environment, such as the color scheme.
public protocol ArtworkStyle: DynamicProperty {
    /// A view that represents the body of an artwork.
    associatedtype Body: View

    /// The properties of an artwork.
    typealias Configuration = ArtworkStyleConfiguration

    /// Creates a view that represents the body of an artwork.
    ///
    /// The system calls this method for each ``Artwork`` instance in a view
    /// hierarchy where this style is the current artwork style.
    ///
    /// - Parameter configuration: The properties of the artwork.
    /// - Returns: A view that represents the body of an artwork.
    @ViewBuilder @MainActor
    func makeBody(configuration: Configuration) -> Body
}
