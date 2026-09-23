import SFSafeSymbols
import SwiftUI

/// A mark on an avatar's lower edge, saying something about the person.
///
/// ```swift
/// Avatar(url: attendee.photoURL, status: AvatarStatus("Checked in"))
/// ```
///
/// The mark carries a symbol as well as a color, so it still reads when colors do not.
///
/// It is about a quarter of the avatar, so give it ``AvatarSize/medium`` or larger. On
/// ``AvatarSize/small`` the mark is under eight points and nobody can read it.
public struct AvatarStatus: Equatable {
    let label: LocalizedStringKey
    let icon: Icon
    let tint: Color

    /// Creates a status mark.
    ///
    /// - Parameters:
    ///   - label: What the mark means. VoiceOver reads it, and nothing shows it, so write the
    ///     words the person would use: "Checked in", not "green tick".
    ///   - icon: The symbol cut out of the mark. Prefer a bare glyph: the mark supplies the disc,
    ///     so a symbol carrying its own circle draws a second one.
    ///   - tint: The color filling the mark. Use a status color, so the color means the same here
    ///     as everywhere else.
    public init(
        _ label: LocalizedStringKey,
        icon: Icon = Icon(.checkmark),
        tint: Color = .success
    ) {
        self.label = label
        self.icon = icon
        self.tint = tint
    }
}
