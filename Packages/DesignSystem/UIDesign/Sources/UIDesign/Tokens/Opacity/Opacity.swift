import SwiftUI

/// An amount of a color that shows, named for the job it does.
public struct Opacity: Equatable, Hashable, Sendable {
    /// A job an amount of color does.
    private enum Role {
        /// A faint texture over a fill.
        case pattern

        /// An avatar's initials, which stay readable and quieter than a name.
        case initials
    }

    /// The job this opacity does.
    private let role: Role

    /// A faint texture over a fill.
    ///
    /// It grows stronger when someone turns on Differentiate Without Color.
    public static let pattern = Self(role: .pattern)

    /// An avatar's initials, which stay readable and quieter than a name.
    ///
    /// It grows stronger when someone turns on Increase Contrast.
    package static let initials = Self(role: .initials)

    /// Returns the level this opacity has under some accessibility settings.
    ///
    /// - Parameter settings: The accessibility settings to read.
    /// - Returns: The level of color that shows.
    package func level(for settings: AccessibilitySettings) -> OpacityLevel {
        switch role {
        case .pattern: patternLevel(for: settings.differentiation)

        case .initials: initialsLevel(for: settings.contrast)
        }
    }

    /// Returns the level of the initials for a contrast setting.
    ///
    /// - Parameter contrast: The contrast the person asked for.
    /// - Returns: The level of the initials.
    private func initialsLevel(for contrast: ColorSchemeContrast) -> OpacityLevel {
        contrast == .increased ? .percent76 : .percent64
    }

    /// Returns the level of the pattern for a way of telling things apart.
    ///
    /// - Parameter differentiation: How the person needs things told apart.
    /// - Returns: The level of the pattern.
    private func patternLevel(for differentiation: ColorDifferentiation) -> OpacityLevel {
        switch differentiation {
        case .standard: .percent8

        case .withoutColor: .percent20
        }
    }
}
