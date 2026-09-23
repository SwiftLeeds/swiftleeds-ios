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

    // The base size differs per avatar, so the metric scales 1 and multiplies.
    @ScaledMetric(relativeTo: .body) private var textScale: CGFloat = 1

    private let url: URL?
    private let size: CGFloat
    private let status: AvatarStatus?
    private let fallback: Fallback

    /// Creates an avatar that draws `fallback` while its photo is missing.
    ///
    /// - Parameters:
    ///   - url: Where the photo loads from. A `nil` url draws the fallback and asks for nothing.
    ///   - size: A diameter from ``AvatarSize``. It grows with the text size, then stops.
    ///   - status: What to mark the avatar's lower edge with, if anything.
    ///   - fallback: What to draw instead of the photo.
    public init(
        url: URL?,
        size: CGFloat = AvatarSize.medium,
        status: AvatarStatus? = nil,
        @ViewBuilder fallback: () -> Fallback
    ) {
        self.url = url
        self.size = size
        self.status = status
        self.fallback = fallback()
    }

    // The scaling and its ceiling belong here, not to a style: a style decides the shape, and
    // every avatar answers the text size the same way.
    public var body: some View {
        AnyView(style.makeBody(configuration: configuration))
            .environment(\.avatarDiameter, diameter)
    }

    private var configuration: AvatarStyleConfiguration {
        AvatarStyleConfiguration(content: content, size: diameter, status: status)
    }

    private var diameter: CGFloat {
        size * min(textScale, Self.largestGrowth)
    }

    // Past this an avatar crowds the text beside it out of the row.
    private static var largestGrowth: CGFloat { 1.75 }

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
    ///   - status: What to mark the avatar's lower edge with, if anything.
    ///   - fallback: What to draw instead of the photo.
    init(
        url: URL?,
        size: CGFloat = AvatarSize.medium,
        status: AvatarStatus? = nil,
        fallback: AvatarFallback = .symbol
    ) {
        self.init(url: url, size: size, status: status) { fallback }
    }
}

private let previewName = PersonNameComponents(givenName: "Member", familyName: "One")

#Preview("Sizes") {
    HStack(alignment: .bottom, spacing: Spacing.large) {
        Avatar(url: nil, size: AvatarSize.small)
        Avatar(url: nil, size: AvatarSize.medium)
        Avatar(url: nil, size: AvatarSize.large)
        Avatar(url: nil, size: AvatarSize.xLarge)
    }
    .padding(Spacing.large)
}

#Preview("Fallbacks") {
    HStack(spacing: Spacing.large) {
        Avatar(url: nil, size: AvatarSize.xLarge)

        Avatar(url: nil, size: AvatarSize.xLarge, fallback: .initials(previewName))

        // A fallback of the caller's own. Neutral, because a color here would read as a status.
        Avatar(url: nil, size: AvatarSize.xLarge) {
            Image(icon: .locked)
                .foregroundStyle(.textSecondary)
        }
    }
    .padding(Spacing.large)
}

#Preview("Styles and status") {
    VStack(alignment: .leading, spacing: Spacing.large) {
        HStack(spacing: Spacing.large) {
            Avatar(url: nil, size: AvatarSize.large, status: AvatarStatus("Checked in"))

            Avatar(
                url: nil,
                size: AvatarSize.large,
                status: AvatarStatus("Waitlisted", icon: .warning, tint: .warning)
            )
        }

        HStack(spacing: Spacing.large) {
            Avatar(url: nil, size: AvatarSize.large, status: AvatarStatus("Checked in"))

            Avatar(url: nil, size: AvatarSize.large)
                .avatarStyle(.rounded(cornerRadius: CornerRadius.small))
        }
        .avatarStyle(.rounded)
    }
    .padding(Spacing.large)
}
