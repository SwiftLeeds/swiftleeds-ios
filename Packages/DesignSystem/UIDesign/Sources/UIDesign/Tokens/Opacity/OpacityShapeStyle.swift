import SwiftUI

/// A shape style that draws another style at an opacity, read from the accessibility settings.
struct OpacityShapeStyle<Base: ShapeStyle>: ShapeStyle {
    /// The style to draw at the opacity.
    private let base: Base

    /// The opacity to draw the base style at.
    private let opacity: Opacity

    /// Creates a style that draws a base style at an opacity.
    ///
    /// - Parameters:
    ///   - base: The style to draw.
    ///   - opacity: The opacity to draw the base style at.
    init(base: Base, opacity: Opacity) {
        self.base = base
        self.opacity = opacity
    }

    /// Evaluates to a resolved shape style given the current environment.
    ///
    /// - Parameter environment: The environment to read the accessibility settings from.
    /// - Returns: The base style, at the level the opacity has in `environment`.
    func resolve(in environment: EnvironmentValues) -> some ShapeStyle {
        base.opacity(Double(opacity.level(for: environment.accessibilitySettings)))
    }
}
