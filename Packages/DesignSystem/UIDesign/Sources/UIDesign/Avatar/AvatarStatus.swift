import SFSafeSymbols
import SwiftUI

/// A state shown on an ``Avatar``.
///
/// ```swift
/// Avatar(url: attendee.photoURL, status: AvatarStatus("Checked in"))
/// ```
///
/// It carries a symbol as well as a color, so it still reads when colors do not, and a label for
/// anyone who cannot see it at all.
///
/// Give it a filled symbol that encloses its own glyph, such as `checkmark.circle.fill`. The
/// enclosure is what gets drawn, and the glyph sits where Apple centered it.
///
/// The ``AvatarStyle`` decides where it sits.
public struct AvatarStatus: Equatable {
    /// What the status means, for anyone who cannot see it.
    let label: LocalizedStringKey

    /// The symbol that encloses its own glyph.
    let icon: Icon

    /// The colors of the enclosure and of the glyph inside it.
    let family: ColorFamily

    /// Creates a status that uses the success colors.
    ///
    /// - Parameters:
    ///   - label: What the status means. VoiceOver reads it, and nothing shows it, so write the
    ///     words the person would use: "Checked in", not "green tick".
    ///   - icon: A filled symbol that encloses its own glyph and means success.
    public init(
        _ label: LocalizedStringKey,
        icon: Icon = Icon(.checkmarkCircleFill),
    ) {
        self.init(label, icon: icon, family: .success)
    }

    /// Creates a status that uses the colors of a family.
    ///
    /// - Parameters:
    ///   - label: What the status means. VoiceOver reads it, and nothing shows it, so write the
    ///     words the person would use: "Checked in", not "green tick".
    ///   - icon: A filled symbol that encloses its own glyph and means the same as the family.
    ///   - family: The colors of the mark. Its strong fill goes behind the glyph, and the glyph
    ///     takes the color made for that fill. Use a status family (``ColorFamily/success``,
    ///     ``ColorFamily/warning``, ``ColorFamily/error`` or ``ColorFamily/info``), so the color
    ///     means the same here as everywhere else.
    package init(
        _ label: LocalizedStringKey,
        icon: Icon,
        family: ColorFamily,
    ) {
        self.label = label
        self.icon = icon
        self.family = family
    }
}
