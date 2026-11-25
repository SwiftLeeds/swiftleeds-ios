#if canImport(SwiftUI)
import CoreGraphics
import SwiftUI

extension CGImage {
    /// The reason a view could not be drawn as an image.
    package enum RenderingError: Error, Equatable, Hashable, Sendable {
        /// SwiftUI draws the view as no image.
        case noImage
    }

    /// Returns a view drawn as an image.
    ///
    /// ```swift
    /// let image = try CGImage.rendering(Color.red.frame(width: 4, height: 4), atScale: 2)
    /// let width = image.width  // 8
    /// ```
    ///
    /// - Parameters:
    ///   - view: The view to draw.
    ///   - scale: The pixels in one point of the image.
    /// - Returns: The drawn image.
    /// - Throws: ``RenderingError/noImage`` when SwiftUI draws the view as no image.
    @MainActor
    package static func rendering(_ view: some View, atScale scale: CGFloat) throws(RenderingError) -> CGImage {
        let renderer = ImageRenderer(content: view)
        renderer.scale = scale
        guard let image = renderer.cgImage else { throw .noImage }
        return image
    }
}
#endif
