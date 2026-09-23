import SwiftUI

/// A person, drawn as their photo.
///
/// The photo loads from `url`. Until it arrives, and if it never does, the avatar draws the
/// fallback instead.
///
/// ```swift
/// Avatar(url: speaker.photoURL, size: AvatarSize.large) {
///     CompanyMark(speaker.company)
/// }
/// ```
///
/// The style clips the avatar to its shape, so a fallback cannot draw outside it.
///
/// An avatar is not a control. Give a tappable one a target of at least 44 points, which
/// ``AvatarSize/small`` and ``AvatarSize/medium`` do not reach on their own.
public struct Avatar<Fallback: View>: View {
    @Environment(\.avatarStyle) private var style

    private let url: URL?
    private let size: CGFloat
    private let fallback: Fallback

    /// Creates an avatar that draws `fallback` while its photo is missing.
    ///
    /// - Parameters:
    ///   - url: Where the photo loads from. A `nil` url draws the fallback and asks for nothing.
    ///   - size: A diameter from ``AvatarSize``. It grows with the text size, then stops.
    ///   - fallback: What to draw instead of the photo.
    public init(
        url: URL?,
        size: CGFloat = AvatarSize.medium,
        @ViewBuilder fallback: () -> Fallback
    ) {
        self.url = url
        self.size = size
        self.fallback = fallback()
    }

    public var body: some View {
        AnyView(style.makeBody(configuration: AvatarStyleConfiguration(content: content, size: size)))
    }

    private var content: some View {
        AsyncImage(url: url) { phase in
            if case .success(let image) = phase {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                fallback
            }
        }
        .accessibilityHidden(true)
    }
}

public extension Avatar where Fallback == AvatarFallback {
    /// Creates an avatar that draws a built-in fallback while its photo is missing.
    ///
    /// - Parameters:
    ///   - url: Where the photo loads from. A `nil` url draws the fallback and asks for nothing.
    ///   - size: A diameter from ``AvatarSize``. It grows with the text size, then stops.
    ///   - fallback: What to draw instead of the photo.
    init(url: URL?, size: CGFloat = AvatarSize.medium, fallback: AvatarFallback = .symbol) {
        self.init(url: url, size: size) { fallback }
    }
}
