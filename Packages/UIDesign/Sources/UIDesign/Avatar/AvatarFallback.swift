import SwiftUI

/// What an ``Avatar`` draws when it has no photo.
///
/// ```swift
/// Avatar(url: profile.avatarURL)
/// Avatar(url: profile.avatarURL, fallback: .initials(profile.name))
/// ```
///
/// It is neutral, because a color on an avatar means the person's status.
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
        LinearGradient(
            colors: [.secondarySurface, .tertiarySurface],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay { drawnMark }
    }

    // Sized from the avatar, not from the text: a mark that follows the text size overflows a
    // small avatar at the accessibility sizes. The avatar itself already grows with the text.
    @ViewBuilder
    private var drawnMark: some View {
        switch mark {
        case .symbol:
            symbol
        case .initials(let name):
            let initials = name.formatted(.name(style: .abbreviated))
            if initials.isEmpty {
                symbol
            } else {
                // Primary, not secondary: at the smaller sizes these letters fall under the text
                // size that a 3:1 contrast ratio is enough for.
                Text(initials)
                    .font(.system(size: diameter * Self.initialsProportion, weight: .semibold))
                    .foregroundStyle(.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
    }

    // A font size keeps the symbol's own proportions, which resizing it would not.
    private var symbol: some View {
        Image(icon: .person)
            .font(.system(size: diameter * Self.symbolProportion))
            .foregroundStyle(.textSecondary)
    }

    // How much of the avatar each mark covers. Any more and it meets the edge.
    private static var symbolProportion: CGFloat { 0.62 }
    private static var initialsProportion: CGFloat { 0.46 }
}

public extension AvatarFallback {
    /// A person symbol, which is what an avatar draws unless its caller says otherwise.
    static var symbol: AvatarFallback { AvatarFallback(.symbol) }

    /// The person's initials, abbreviated the way their name's locale abbreviates it.
    ///
    /// A name that abbreviates to more than two letters shrinks to fit. A name with nothing to
    /// abbreviate draws the symbol instead.
    static func initials(_ name: PersonNameComponents) -> AvatarFallback {
        AvatarFallback(.initials(name))
    }
}
