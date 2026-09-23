import SFSafeSymbols
import SwiftUI

/// A state shown on an ``Avatar``.
///
/// ```swift
/// Avatar(url: attendee.photoURL, status: AvatarStatus("Checked in"))
/// ```
///
/// It carries a symbol as well as a color, so it still reads when colors do not, and a label,
/// because nothing on screen spells it out.
///
/// Give it a filled symbol that encloses its own glyph, such as `checkmark.circle.fill`. The
/// enclosure is what gets drawn, and the glyph sits where Apple centered it.
///
/// The ``AvatarStyle`` decides where it sits and how large it is.
public struct AvatarStatus: Equatable {
    let label: LocalizedStringKey
    let icon: Icon
    let tint: Color

    /// Creates a status.
    ///
    /// - Parameters:
    ///   - label: What the status means. VoiceOver reads it, and nothing shows it, so write the
    ///     words the person would use: "Checked in", not "green tick".
    ///   - icon: A filled symbol that encloses its own glyph.
    ///   - tint: The color of the enclosure. Use a status color, so the color means the same here
    ///     as everywhere else.
    public init(
        _ label: LocalizedStringKey,
        icon: Icon = Icon(.checkmarkCircleFill),
        tint: Color = .success
    ) {
        self.label = label
        self.icon = icon
        self.tint = tint
    }
}
