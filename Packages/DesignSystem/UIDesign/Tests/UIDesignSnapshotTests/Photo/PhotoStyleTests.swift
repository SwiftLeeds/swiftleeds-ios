#if os(iOS)
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite
struct PhotoStyleTests {
    /// A photo style that draws a word of its own and ignores the photo's content.
    private struct WordPhotoStyle: PhotoStyle {
        /// The word the style draws.
        static let word = "Custom style"

        func makeBody(configuration: Configuration) -> some View {
            Text(Self.word)
        }
    }

    /// A photo style that draws the color scheme it reads from the environment as a word.
    private struct ColorSchemePhotoStyle: PhotoStyle {
        /// The color scheme the style reads from the environment.
        @Environment(\.colorScheme) private var colorScheme

        func makeBody(configuration: Configuration) -> some View {
            Text(colorScheme == .dark ? "dark" : "light")
        }
    }

    @Test
    func whenCustomStyleIsSet_shouldDrawStylesOwnBody() throws {
        let view = Photo(url: nil).photoStyle(WordPhotoStyle())
        let elements = try AccessibilityTree.elements(of: view)
        #expect(elements.map(\.label) == [WordPhotoStyle.word])
    }

    @Test
    func whenNoStyleIsSet_shouldExposeNoElement() throws {
        let elements = try AccessibilityTree.elements(of: Photo(url: nil) { Text("Fallback") })
        #expect(elements.isEmpty)
    }

    @Test(arguments: [(ColorScheme.dark, "dark"), (ColorScheme.light, "light")])
    func whenRenderedInColorScheme_shouldReadSchemeInStyle(scheme: ColorScheme, word: String) throws {
        let view = Photo(url: nil)
            .photoStyle(ColorSchemePhotoStyle())
            .environment(\.colorScheme, scheme)
        let elements = try AccessibilityTree.elements(of: view)
        #expect(elements.map(\.label) == [word])
    }
}
#endif
