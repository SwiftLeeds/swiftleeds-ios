import SwiftUI

/// What an ``Avatar`` draws when it has no photo.
///
/// ```swift
/// Avatar(url: profile.avatarURL)
/// ```
///
/// It is neutral, because a color on an avatar means the person's status.
public struct AvatarFallback: View {
    @Environment(\.avatarDiameter) private var diameter

    private init() {}

    public var body: some View {
        LinearGradient(
            colors: [.secondarySurface, .tertiarySurface],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay { mark }
    }

    // Sized from the avatar, not from the text: a symbol that follows the text size overflows a
    // small avatar at the accessibility sizes. A font size keeps the symbol's own proportions,
    // which resizing it would not.
    private var mark: some View {
        Image(icon: .person)
            .font(.system(size: diameter * Self.markProportion))
            .foregroundStyle(.textSecondary)
    }

    // How much of the avatar the mark covers. Any more and it meets the edge.
    private static var markProportion: CGFloat { 0.5 }
}

public extension AvatarFallback {
    /// A person symbol, which is what an avatar draws unless its caller says otherwise.
    static var symbol: AvatarFallback { AvatarFallback() }
}
