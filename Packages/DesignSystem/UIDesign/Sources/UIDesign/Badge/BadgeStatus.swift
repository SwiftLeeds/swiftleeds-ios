import SFSafeSymbols
import SwiftUI

/// A state that a badge marks, with a color family and an icon of its own.
///
/// A status marks what needs attention, not a mood. Green is for success only and red is for
/// error only. The word carries the meaning, and the icon and color support it.
///
/// A badge status is one of four fixed states. A badge with a status ignores
/// ``SwiftUI/View/badgePalette(_:)``.
///
/// ```swift
/// Badge("Cancelled", status: .error)
/// ```
public struct BadgeStatus: Equatable, Hashable, Sendable {
    /// The colors the status draws with.
    let colors: ColorFamily

    /// The icon a badge draws before its word.
    let icon: Icon

    /// A status for something that worked, such as a confirmed seat.
    public static let success = Self(colors: .success, icon: Icon(.checkmarkCircleFill))

    /// A status for something that needs a look, such as few seats left.
    public static let warning = Self(
        colors: .warning,
        icon: Icon(.exclamationmarkTriangleFill),
    )

    /// A status for something that failed, such as a cancelled session.
    public static let error = Self(colors: .error, icon: Icon(.xmarkOctagonFill))

    /// A status for something to know, such as a new session.
    public static let info = Self(colors: .info, icon: Icon(.infoCircleFill))

    /// Creates a status that draws with a color family and an icon.
    ///
    /// - Parameters:
    ///   - colors: The colors the status draws with.
    ///   - icon: The icon the status draws before the word.
    private init(colors: ColorFamily, icon: Icon) {
        self.colors = colors
        self.icon = icon
    }
}
