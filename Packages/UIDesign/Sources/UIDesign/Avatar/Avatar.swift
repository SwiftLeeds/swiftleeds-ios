import SFSafeSymbols
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
    private let size: AvatarSize
    private let status: AvatarStatus?
    private let fallback: Fallback

    /// Creates an avatar that draws `fallback` while its photo is missing.
    ///
    /// - Parameters:
    ///   - url: Where the photo loads from. A `nil` url draws the fallback and asks for nothing.
    ///   - size: A diameter from ``AvatarSize``. It grows with the text size, then stops.
    ///   - status: The state to show on the avatar, if any. The style decides where it goes.
    ///   - fallback: What to draw instead of the photo.
    public init(
        url: URL?,
        size: AvatarSize = .medium,
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
        AvatarStyleConfiguration(content: content, size: diameter, status: mark)
    }

    private var mark: AvatarStatusMark? {
        status.map { AvatarStatusMark(status: $0, avatarDiameter: diameter) }
    }

    private var diameter: AvatarSize {
        size.scaled(by: min(textScale, Self.largestGrowth))
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
    ///   - status: The state to show on the avatar, if any. The style decides where it goes.
    ///   - fallback: What to draw instead of the photo.
    init(
        url: URL?,
        size: AvatarSize = .medium,
        status: AvatarStatus? = nil,
        fallback: AvatarFallback = .symbol
    ) {
        self.init(url: url, size: size, status: status) { fallback }
    }
}

private let previewName = PersonNameComponents(givenName: "Member", familyName: "One")

#Preview("Sizes") {
    HStack(alignment: .bottom, spacing: .large) {
        Avatar(url: nil, size: .small)
        Avatar(url: nil, size: .medium)
        Avatar(url: nil, size: .large)
        Avatar(url: nil, size: .xLarge)
    }
    .padding(.large)
}

#Preview("Fallbacks") {
    HStack(spacing: .large) {
        Avatar(url: nil, size: .xLarge)

        Avatar(url: nil, size: .xLarge, fallback: .initials(previewName))

        // A fallback of the caller's own. Neutral, because a color here would read as a status.
        Avatar(url: nil, size: .xLarge) {
            Image(icon: .locked)
                .foregroundStyle(.textSecondary)
        }
    }
    .padding(.large)
}

#Preview("Styles and status") {
    VStack(alignment: .leading, spacing: .large) {
        HStack(spacing: .large) {
            Avatar(url: nil, size: .large, status: AvatarStatus("Checked in"))

            Avatar(
                url: nil,
                size: .large,
                status: AvatarStatus(
                    "Waitlisted",
                    icon: Icon(.exclamationmarkCircleFill),
                    tint: .warning
                )
            )
        }

        HStack(spacing: .large) {
            Avatar(url: nil, size: .large, status: AvatarStatus("Checked in"))

            Avatar(url: nil, size: .large)
                .avatarStyle(.rounded(cornerRadius: .small))
        }
        .avatarStyle(.rounded)
    }
    .padding(.large)
}
