import SwiftUI

/// A view that stands in for an avatar's photo when there is none.
///
/// ```swift
/// Avatar(url: profile.avatarURL, fallback: .initials(profile.name))
/// Avatar(url: profile.avatarURL)
/// ```
///
/// The circle stays neutral. A color here would have to mean something, and
/// the initials already tell one person from another.
public struct AvatarFallback: View {
    /// What the fallback draws in place of the photo.
    private enum Mark {
        /// A person symbol, for someone the app cannot name.
        case symbol

        /// The person's initials.
        case initials(PersonNameComponents)
    }

    /// The diameter of the avatar containing this view.
    @Environment(\.avatarDiameter) private var diameter

    /// What this fallback draws.
    private let mark: Mark

    /// Creates a fallback that draws the given mark.
    ///
    /// - Parameter mark: What to draw in place of the photo.
    private init(_ mark: Mark) {
        self.mark = mark
    }

    public var body: some View {
        switch mark {
        case .symbol:
            symbol
        case .initials(let name):
            initials(of: name)
        }
    }

    /// Returns the person's initials, or the symbol when there is nothing to
    /// abbreviate.
    ///
    /// The letters take their size from the avatar rather than from the text
    /// size, which the avatar has already answered.
    ///
    /// - Parameter name: The name to abbreviate.
    @ViewBuilder
    private func initials(of name: PersonNameComponents) -> some View {
        let letters = name.formatted(.name(style: .abbreviated))
        if letters.isEmpty {
            symbol
        } else {
            Color.secondarySurface
                .overlay {
                    Text(letters)
                        .font(.system(size: CGFloat(diameter) * Self.initialsProportion, weight: .semibold))
                        .foregroundStyle(.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
        }
    }

    // A font size keeps the symbol's own proportions, which resizing it would not.
    private var symbol: some View {
        Color.secondarySurface
            .overlay {
                Image(icon: .person)
                    .font(.system(size: CGFloat(diameter) * Self.symbolProportion))
                    .foregroundStyle(.textSecondary)
            }
    }

    // How much of the avatar each mark covers. Any more and it meets the edge.
    private static var symbolProportion: CGFloat { 0.62 }
    private static var initialsProportion: CGFloat { 0.46 }
}

public extension AvatarFallback {
    /// A person symbol on a plain fill, for someone the app cannot name.
    static var symbol: AvatarFallback { AvatarFallback(.symbol) }

    /// The person's initials on a plain fill.
    ///
    /// The name's locale decides how the initials are abbreviated. A name with
    /// nothing to abbreviate draws the symbol instead.
    ///
    /// - Parameter name: The name to abbreviate.
    static func initials(_ name: PersonNameComponents) -> AvatarFallback {
        AvatarFallback(.initials(name))
    }
}
