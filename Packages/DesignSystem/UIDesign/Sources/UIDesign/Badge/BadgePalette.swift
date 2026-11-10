import SwiftUI

/// A set of colors for a badge.
///
/// To set the palette of the badges within a view hierarchy, use the
/// ``SwiftUI/View/badgePalette(_:)`` modifier.
public struct BadgePalette: Equatable, Hashable, Sendable {
    /// The colors this palette draws with.
    fileprivate let family: ColorFamily

    /// A neutral palette with no hue.
    public static let neutral = Self(family: .neutral)

    /// A blue palette.
    public static let blue = Self(family: .blue)

    /// A teal palette.
    public static let teal = Self(family: .teal)

    /// A violet palette.
    public static let violet = Self(family: .violet)

    /// A raspberry palette.
    public static let raspberry = Self(family: .raspberry)

    /// The palette for sponsors.
    public static let sponsor = Self(family: .sponsor)
}

extension BadgePalette {
    /// The colors a badge draws with.
    package var colors: ColorFamily { family }
}
