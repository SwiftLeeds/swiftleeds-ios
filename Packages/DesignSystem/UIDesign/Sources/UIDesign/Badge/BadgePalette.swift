import SwiftUI

/// A set of colors for a badge.
///
/// To set the palette of the badges within a view hierarchy, use the
/// ``SwiftUI/View/badgePalette(_:)`` modifier.
public struct BadgePalette: Equatable, Hashable, Sendable {
    /// The colors the palette draws with.
    let colors: ColorFamily

    /// A neutral palette with no hue.
    public static let neutral = Self(colors: .neutral)

    /// A blue palette.
    public static let blue = Self(colors: .blue)

    /// A teal palette.
    public static let teal = Self(colors: .teal)

    /// A violet palette.
    public static let violet = Self(colors: .violet)

    /// A raspberry palette.
    public static let raspberry = Self(colors: .raspberry)

    /// The palette for sponsors.
    public static let sponsor = Self(colors: .sponsor)

    /// Creates a palette that draws with a color family.
    ///
    /// - Parameter colors: The colors the palette draws with.
    private init(colors: ColorFamily) {
        self.colors = colors
    }
}
