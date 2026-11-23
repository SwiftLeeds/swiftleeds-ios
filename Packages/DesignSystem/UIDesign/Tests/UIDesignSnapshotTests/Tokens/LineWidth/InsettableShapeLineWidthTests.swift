#if os(iOS)
import SwiftUI
import Testing
import UIDesign

@MainActor
struct InsettableShapeLineWidthTests {
    /// The side of the square that each circle is drawn in, in points.
    private static let side: CGFloat = 40

    /// Returns the pixels of a circle stroked inside its edge, at one pixel to the point.
    ///
    /// - Parameter stroke: The circle, stroked.
    /// - Returns: The pixels of the circle in a fixed square.
    /// - Throws: When the circle cannot be rendered or its pixels cannot be read.
    private static func pixels(of stroke: some View) throws -> Pixels {
        let renderer = ImageRenderer(content: stroke.frame(width: side, height: side))
        renderer.scale = 1
        let image = try #require(renderer.cgImage)
        return try Pixels(of: image, scale: 1)
    }

    @Test
    func whenStrokedWithRing_shouldDrawSamePixelsAsThreePoints() throws {
        let sut = try Self.pixels(of: Circle().strokeBorder(.black, lineWidth: .ring))
        let threePoints = try Self.pixels(of: Circle().strokeBorder(.black, lineWidth: 3))
        let fivePoints = try Self.pixels(of: Circle().strokeBorder(.black, lineWidth: 5))
        #expect(sut == threePoints)
        #expect(sut != fivePoints)
    }
}
#endif
