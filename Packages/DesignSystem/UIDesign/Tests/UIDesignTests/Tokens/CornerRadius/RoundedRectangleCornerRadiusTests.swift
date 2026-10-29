import CoreGraphics
import SwiftUI
import Testing
import UIDesign

/// Tests for the ``RoundedRectangle`` initializer that takes a ``CornerRadius``.
struct RoundedRectangleCornerRadiusTests {
    /// Checks that the tile corner radius gives corners of 8 points.
    @Test
    func whenCreatedWithTileCornerRadius_shouldReturnEightPointCorners() {
        let sut = RoundedRectangle(cornerRadius: .tile)
        #expect(sut.cornerSize == CGSize(width: 8, height: 8))
    }

    /// Checks that the corners use the continuous style by default.
    @Test
    func whenCreatedWithTileCornerRadius_shouldReturnContinuousStyle() {
        let sut = RoundedRectangle(cornerRadius: .tile)
        #expect(sut.style == .continuous)
    }
}
