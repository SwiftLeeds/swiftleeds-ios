#if os(iOS)
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite
struct AvatarStyleTests {
    /// An avatar style that draws the color scheme it reads from the environment as a word.
    private struct ColorSchemeAvatarStyle: AvatarStyle {
        /// The color scheme the style reads from the environment.
        @Environment(\.colorScheme) private var colorScheme

        func makeBody(configuration: Configuration) -> some View {
            Text(colorScheme == .dark ? "dark" : "light")
        }
    }

    @Test(arguments: [(ColorScheme.dark, "dark"), (ColorScheme.light, "light")])
    func whenStyleReadsColorScheme_shouldDrawCurrentScheme(scheme: ColorScheme, word: String) throws {
        let view = Avatar(url: nil)
            .avatarStyle(ColorSchemeAvatarStyle())
            .environment(\.colorScheme, scheme)
        let elements = try AccessibilityTree.elements(of: view)
        #expect(elements.map(\.label) == [word])
    }
}
#endif
