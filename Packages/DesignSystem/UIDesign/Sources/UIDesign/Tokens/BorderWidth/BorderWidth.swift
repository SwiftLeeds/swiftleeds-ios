import SwiftUI

/// The width of an edge, named for the job it does.
public struct BorderWidth: Equatable, Hashable, Sendable {
    /// A job an edge does.
    private enum Role {
        /// The edge that keeps a shape visible on a surface of the same color.
        case edge

        /// The outline that sets a shape apart under Increase Contrast.
        case outline
    }

    /// The job this border width does.
    private let role: Role

    /// The edge that keeps a shape visible on a surface of the same color.
    ///
    /// It keeps its width under every accessibility setting.
    public static let edge = Self(role: .edge)

    /// The outline that sets a shape apart under Increase Contrast.
    ///
    /// It draws nothing otherwise.
    package static let outline = Self(role: .outline)

    /// Returns the level this border width has under some accessibility settings.
    ///
    /// - Parameter settings: The accessibility settings to read.
    /// - Returns: The level of the border width.
    package func level(for settings: AccessibilitySettings) -> BorderWidthLevel {
        switch role {
        case .edge: .thin
        case .outline: outlineLevel(for: settings)
        }
    }

    /// Returns the level of the outline under some accessibility settings.
    ///
    /// - Parameter settings: The accessibility settings to read.
    /// - Returns: The medium level under Increase Contrast, and the zero level otherwise.
    private func outlineLevel(for settings: AccessibilitySettings) -> BorderWidthLevel {
        settings.contrast == .increased ? .medium : .zero
    }
}
