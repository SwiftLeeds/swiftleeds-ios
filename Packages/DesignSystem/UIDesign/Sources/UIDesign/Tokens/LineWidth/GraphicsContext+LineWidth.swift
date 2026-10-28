import SwiftUI

extension GraphicsContext {
    /// Draws a path into the context with a line width token.
    ///
    /// The token reads the accessibility settings from the context's environment.
    ///
    /// - Parameters:
    ///   - path: The path to outline.
    ///   - shading: The color or pattern to use when outlining the path.
    ///   - lineWidth: The line width token to outline the path with.
    public func stroke(_ path: Path, with shading: Shading, lineWidth: LineWidth) {
        let level = lineWidth.level(for: environment.accessibilitySettings)
        stroke(path, with: shading, lineWidth: CGFloat(level))
    }
}
