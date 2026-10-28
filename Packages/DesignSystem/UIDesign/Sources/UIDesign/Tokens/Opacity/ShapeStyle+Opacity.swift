import SwiftUI

extension ShapeStyle {
    /// Returns a style based on this one that multiplies by a token's opacity when drawing.
    ///
    /// The amount follows the person's accessibility settings.
    ///
    /// - Parameter opacity: The opacity to apply to the style.
    /// - Returns: A style that draws this style at the opacity.
    public func opacity(_ opacity: Opacity) -> some ShapeStyle {
        OpacityShapeStyle(base: self, opacity: opacity)
    }
}
