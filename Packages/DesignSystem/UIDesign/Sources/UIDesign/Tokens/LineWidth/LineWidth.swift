/// The width of a drawn line, named for the job it does.
public struct LineWidth: Equatable, Hashable, Sendable {
    /// A job a drawn line does.
    private enum Role {
        /// The lines of a faint texture over a fill.
        case pattern
    }

    /// The job this line width does.
    private let role: Role

    /// The lines of a faint texture over a fill.
    ///
    /// It keeps its width under every accessibility setting.
    public static let pattern = Self(role: .pattern)

    /// Returns the level this line width has under some accessibility settings.
    ///
    /// - Parameter settings: The accessibility settings to read.
    /// - Returns: The level of the line width.
    package func level(for settings: AccessibilitySettings) -> LineWidthLevel {
        switch role {
        case .pattern: .points3
        }
    }
}
