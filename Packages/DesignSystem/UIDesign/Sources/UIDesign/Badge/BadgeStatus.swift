import SFSafeSymbols
import SwiftUI

/// A state that a badge marks, with a color family and an icon of its own.
///
/// A status marks what needs attention, not a mood. Green is for success only and red is for
/// error only. The word carries the meaning, and the icon and color support it.
///
/// Unlike ``AvatarStatus``, which is a label, an icon and a family for an avatar, a badge status
/// is one of four fixed states. A badge with a status ignores ``SwiftUI/View/badgePalette(_:)``.
///
/// ```swift
/// Badge("Cancelled", status: .error)
/// ```
public struct BadgeStatus: Equatable, Hashable, Sendable {
    /// The colors this status draws with.
    fileprivate let family: ColorFamily

    /// The icon this status draws.
    fileprivate let icon: Icon

    /// A status for something that worked, such as a confirmed seat.
    public static let success = Self(family: .success, icon: Icon(.checkmarkCircleFill))

    /// A status for something that needs a look, such as few seats left.
    public static let warning = Self(family: .warning, icon: Icon(.exclamationmarkTriangleFill))

    /// A status for something that failed, such as a cancelled session.
    public static let error = Self(family: .error, icon: Icon(.xmarkOctagonFill))

    /// A status for something to know, such as a new session.
    public static let info = Self(family: .info, icon: Icon(.infoCircleFill))
}

extension BadgeStatus {
    /// The colors a badge draws with.
    package var colors: ColorFamily { family }

    /// The icon a badge draws before its word.
    package var symbol: Icon { icon }
}
