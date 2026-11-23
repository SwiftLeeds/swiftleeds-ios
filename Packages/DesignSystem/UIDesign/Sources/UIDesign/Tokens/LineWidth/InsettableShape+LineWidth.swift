import SwiftUI

extension InsettableShape {
    /// Returns a view that strokes the inside of this shape with a line width token.
    ///
    /// The token reads the accessibility settings from the environment.
    ///
    /// - Parameters:
    ///   - content: The color or gradient to stroke the border with.
    ///   - lineWidth: The line width token for the stroke inside the shape's edge.
    /// - Returns: A view that strokes the inside of the shape's edge at the token's width.
    package func strokeBorder(_ content: some ShapeStyle, lineWidth: LineWidth) -> some View {
        LineWidthStroke(shape: self, content: content, lineWidth: lineWidth)
    }
}
