import SwiftUI
import Testing
import UIDesign

/// Tests for the frame modifiers that take a size token.
@MainActor
struct FrameSizeTests {
    /// Checks that a view framed with an icon size renders at the token's size.
    @Test
    func whenViewIsFramedWithIconSize_shouldRenderAtTokenSize() throws {
        let renderer = ImageRenderer(content: Color.clear.frame(iconSize: .small))
        renderer.scale = 1
        let image = try #require(renderer.cgImage)
        #expect(CGFloat(image.width) == CGFloat(IconSize.small))
        #expect(CGFloat(image.height) == CGFloat(IconSize.small))
    }
}
