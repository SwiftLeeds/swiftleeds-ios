import SwiftUI

/// A mark on an avatar's lower edge, saying something about the person.
///
/// ```swift
/// Avatar(url: attendee.photoURL, status: AvatarStatus("Checked in"))
/// ```
///
/// The mark carries a symbol as well as a color, so it still reads when colors do not.
public struct AvatarStatus: Equatable {
    let label: LocalizedStringKey
    let icon: Icon
    let tint: Color

    /// Creates a status mark.
    ///
    /// - Parameters:
    ///   - label: What the mark means. VoiceOver reads it, and nothing shows it, so write the
    ///     words the person would use: "Checked in", not "green tick".
    ///   - icon: The symbol in the mark.
    ///   - tint: The color behind the symbol. Use a status color, so the color means the same
    ///     here as everywhere else.
    public init(_ label: LocalizedStringKey, icon: Icon = .success, tint: Color = .success) {
        self.label = label
        self.icon = icon
        self.tint = tint
    }
}
