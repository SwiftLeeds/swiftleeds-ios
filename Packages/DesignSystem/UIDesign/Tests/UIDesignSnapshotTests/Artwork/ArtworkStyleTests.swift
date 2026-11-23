#if os(iOS)
import SwiftUI
import Testing
import UIDesign

/// Tests that an artwork draws through the style in its environment.
@MainActor
@Suite
struct ArtworkStyleTests {
    /// A style that draws its own word and ignores the artwork's properties.
    private struct WordArtworkStyle: ArtworkStyle {
        /// The word this style draws.
        static let word = "Drawn by the style"

        /// Creates a view that shows this style's word in place of the artwork.
        ///
        /// - Parameter configuration: The properties of the artwork, which this style ignores.
        /// - Returns: A text view that shows ``word``.
        @MainActor
        func makeBody(configuration: Configuration) -> some View {
            Text(Self.word)
        }
    }

    @Test
    func whenCustomStyleIsSet_shouldDrawStyleWord() throws {
        let view = Artwork(icon: Icon(.hammerFill), palette: .teal)
            .artworkStyle(WordArtworkStyle())
        let elements = try AccessibilityTree.elements(of: view)
        #expect(elements.map(\.label) == [WordArtworkStyle.word])
    }
}
#endif
