import CoreGraphics
import SwiftUI
import Testing
import UIDesign

/// Tests for the `RoundedRectangle` initializer that takes a ``CornerRadius``.
struct RoundedRectangleCornerRadiusTests {
    /// Checks that the tile corner radius gives corners of 8 points.
    @Test
    func whenCreatedWithTileCornerRadius_shouldReturnEightPointCorners() {
        let sut = RoundedRectangle(cornerRadius: .tile)
        #expect(sut.cornerSize == CGSize(width: 8, height: 8))
    }

    /// Checks that the overload passes the corner style through.
    @Test
    func whenCreatedWithCircularStyle_shouldReturnCircularStyle() {
        let sut = RoundedRectangle(cornerRadius: .tile, style: .circular)
        #expect(sut.style == .circular)
    }
}
