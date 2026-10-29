import SwiftUI
import Testing
import UIDesign

/// Tests for the layout initializers that take a ``Spacing``.
struct LayoutSpacingTests {
    /// Checks that a horizontal stack layout created with a token returns the token's points.
    @Test
    func whenHStackLayoutIsCreatedWithSpacingToken_shouldReturnTokenSpacing() {
        let sut = HStackLayout(spacing: .medium)
        #expect(sut.spacing == 12)
    }

    /// Checks that a vertical stack layout created with a token returns the token's points.
    @Test
    func whenVStackLayoutIsCreatedWithSpacingToken_shouldReturnTokenSpacing() {
        let sut = VStackLayout(spacing: .medium)
        #expect(sut.spacing == 12)
    }
}
