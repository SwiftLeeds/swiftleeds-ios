import SwiftUI

extension InsettableShape {
    /// Returns a view that strokes the inside of this shape with a border width token.
    ///
    /// The token reads the accessibility settings from the environment.
    ///
    /// - Parameters:
    ///   - content: The color or gradient to stroke the border with.
    ///   - lineWidth: The border width token for the stroke inside the shape's edge.
    /// - Returns: A view that strokes the inside of the shape's edge at the token's width.
    public func strokeBorder(_ content: some ShapeStyle, lineWidth: BorderWidth) -> some View {
        BorderStroke(shape: self, content: content, lineWidth: lineWidth)
    }
}
