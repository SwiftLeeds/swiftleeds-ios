import SwiftUI

/// What an ``Avatar`` draws when it has no photo.
///
/// ```swift
/// Avatar(url: profile.avatarURL)
/// ```
///
/// It is neutral, because a color on an avatar means the person's status.
public struct AvatarFallback: View {
    private init() {}

    public var body: some View {
        LinearGradient(
            colors: [.secondarySurface, .tertiarySurface],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay { mark }
    }

    // Resizable, not a symbol scale: the mark tracks the avatar's diameter, not the text size.
    private var mark: some View {
        Image(icon: .person)
            .resizable()
            .scaledToFit()
            .scaleEffect(Self.markProportion)
            .foregroundStyle(.textSecondary)
    }

    // How much of the avatar the mark covers. Any more and it meets the edge.
    private static var markProportion: CGFloat { 0.52 }
}

public extension AvatarFallback {
    /// A person symbol, which is what an avatar draws unless its caller says otherwise.
    static var symbol: AvatarFallback { AvatarFallback() }
}
