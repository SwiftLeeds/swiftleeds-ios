#if os(iOS)
import SwiftUI
import Testing
import UIDesign

/// Tests that a logo draws through the style in its environment.
@MainActor
@Suite
struct LogoStyleTests {
    /// A style that draws its own text and ignores the logo's content.
    private struct TextLogoStyle: LogoStyle {
        @MainActor
        func makeBody(configuration: Configuration) -> some View {
            Text(LogoStyleTests.styleText)
        }
    }

    /// A style that draws the name of the color scheme it reads from the environment.
    private struct SchemeLogoStyle: LogoStyle {
        /// The color scheme this style reads.
        @Environment(\.colorScheme) private var colorScheme

        @MainActor
        func makeBody(configuration: Configuration) -> some View {
            Text(colorScheme == .dark ? "dark" : "light")
        }
    }

    /// The words a style draws in place of a logo's content.
    private static let styleText = "Drawn by the style"

    @Test
    func whenStyleIsSet_shouldDrawStyleText() throws {
        let view = Logo(url: nil).logoStyle(TextLogoStyle())
        let elements = try AccessibilityTree.elements(of: view)
        #expect(elements.map(\.label) == [Self.styleText])
    }

    @Test
    func whenNoStyleIsSet_shouldDrawNoText() throws {
        let elements = try AccessibilityTree.elements(of: Logo(url: nil))
        #expect(elements.isEmpty, "The default style drew \(elements.map(\.label))")
    }

    @Test(arguments: [(ColorScheme.dark, "dark"), (ColorScheme.light, "light")])
    func whenStyleReadsColorScheme_shouldDrawSchemeName(scheme: ColorScheme, name: String) throws {
        let view = Logo(url: nil)
            .logoStyle(SchemeLogoStyle())
            .environment(\.colorScheme, scheme)
        let elements = try AccessibilityTree.elements(of: view)
        #expect(elements.map(\.label) == [name])
    }
}
#endif
