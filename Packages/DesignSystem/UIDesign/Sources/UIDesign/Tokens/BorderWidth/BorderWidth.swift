/// The width of an edge, named for the job it does.
public struct BorderWidth: Equatable, Hashable, Sendable {
    /// A job an edge does.
    private enum Role {
        /// The edge that keeps a shape visible on a surface of the same color.
        case edge
    }

    /// The job this border width does.
    private let role: Role

    /// The edge that keeps a shape visible on a surface of the same color.
    ///
    /// It keeps its width under every accessibility setting.
    public static let edge = Self(role: .edge)

    /// Returns the level this border width has under some accessibility settings.
    ///
    /// - Parameter settings: The accessibility settings to read.
    /// - Returns: The level of the border width.
    package func level(for settings: AccessibilitySettings) -> BorderWidthLevel {
        switch role {
        case .edge: .thin
        }
    }
}
