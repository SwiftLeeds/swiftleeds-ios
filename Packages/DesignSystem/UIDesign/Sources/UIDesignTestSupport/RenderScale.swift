#if canImport(CoreGraphics)
import CoreGraphics

/// How many pixels a render draws for each point of a view.
///
/// ```swift
/// let scale = RenderScale(pixelsPerPoint: 2)
/// let pixels = CGFloat(scale)  // 2.0
/// ```
package struct RenderScale: Equatable, Hashable, Sendable {
    /// The pixels in one point.
    fileprivate let pixelsPerPoint: CGFloat

    /// Creates a scale.
    ///
    /// - Parameter pixelsPerPoint: The pixels the render draws for each point.
    package init(pixelsPerPoint: CGFloat) {
        self.pixelsPerPoint = pixelsPerPoint
    }
}

extension CGFloat {
    /// Creates the pixels in one point of a scale.
    ///
    /// - Parameter scale: The scale to read.
    package init(_ scale: RenderScale) {
        self = scale.pixelsPerPoint
    }
}
#endif
