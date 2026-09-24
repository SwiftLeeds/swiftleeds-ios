import SwiftUI

/// What an ``Avatar`` draws when it has no photo.
///
/// ```swift
/// Avatar(url: profile.avatarURL, fallback: .initials(profile.name))
/// Avatar(url: profile.avatarURL)
/// ```
///
/// The circle stays neutral. A color here would have to mean something, and the initials already
/// tell one person from another.
public struct AvatarFallback: View {
    private enum Mark {
        case symbol
        case initials(PersonNameComponents)
    }

    @Environment(\.avatarDiameter) private var diameter

    private let mark: Mark

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

    // Sized from the avatar, not from the text: a mark that follows the text size overflows a
    // small avatar at the accessibility sizes. The avatar itself already grows with the text.
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
    /// A person symbol on a plain circle, for someone we cannot name.
    static var symbol: AvatarFallback { AvatarFallback(.symbol) }

    /// The person's initials on a circle in their own color.
    ///
    /// The initials are abbreviated the way the name's locale abbreviates it. A name with nothing
    /// to abbreviate draws the symbol instead.
    static func initials(_ name: PersonNameComponents) -> AvatarFallback {
        AvatarFallback(.initials(name))
    }
}
