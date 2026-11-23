import SwiftUI

/// A view that strokes the border of a shape with a line width token.
struct LineWidthStroke<Outline: InsettableShape, Content: ShapeStyle>: View {
    /// The shape to outline.
    let shape: Outline

    /// The color or gradient to stroke the border with.
    let content: Content

    /// The line width token to stroke the border with.
    let lineWidth: LineWidth

    /// The accessibility settings the line width reads.
    @Environment(\.accessibilitySettings) private var settings

    /// The shape, stroked inside its edge at its width for the accessibility settings.
    var body: some View {
        shape.strokeBorder(content, lineWidth: CGFloat(lineWidth.level(for: settings)))
    }
}
