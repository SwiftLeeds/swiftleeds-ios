import SwiftUI

/// A set of colors, one for each role, that adapt to dark mode and Increase Contrast.
///
/// Each role has its own tone for light, dark and Increase Contrast, so a view reads a role and
/// never picks a shade.
package enum ColorFamily: CaseIterable, Equatable, Hashable, Sendable {
    /// A job a color does inside a family.
    private enum Role {
        /// The color for text or a symbol on a surface.
        case text
        /// The color for a strong fill.
        case solid
        /// The color for text or a symbol on a strong fill.
        case onSolid
        /// The color for a pale fill.
        case subtle
    }

    /// The family for success.
    case success
    /// The family for a warning.
    case warning
    /// The family for an error.
    case error
    /// The family for information.
    case info
    /// A neutral family with no hue.
    case neutral
    /// A blue family.
    case blue
    /// A teal family.
    case teal
    /// A violet family.
    case violet
    /// A raspberry family.
    case raspberry
    /// The family for sponsors.
    case sponsor

    /// The color for text or a symbol on a surface.
    ///
    /// It reaches 4.5:1 against `surface` and `secondarySurface`.
    package var text: Color { color(for: .text) }

    /// The color for a filled shape behind ``onSolid``, such as a badge or a status dot.
    ///
    /// It reaches 4.5:1 against ``onSolid``. Every family but ``warning`` reaches 3:1 against
    /// `surface` and `secondarySurface`; the warning fill is pale, and its text or symbol carries
    /// the state.
    package var solid: Color { color(for: .solid) }

    /// The color for text or a symbol on ``solid``.
    package var onSolid: Color { color(for: .onSolid) }

    /// The color for a pale fill behind ``text``, such as a badge.
    ///
    /// ``text`` reaches 4.5:1 against it.
    package var subtle: Color { color(for: .subtle) }

    /// Returns the catalog color of this family for a role.
    ///
    /// - Parameter role: The job the color does.
    /// - Returns: The color, named after the family and the role.
    private func color(for role: Role) -> Color {
        Color(ColorResource(name: "\(self)-\(role)", bundle: .module))
    }
}
