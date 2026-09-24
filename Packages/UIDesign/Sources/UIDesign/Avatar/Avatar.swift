import SFSafeSymbols
import SwiftUI

/// A view that shows a person as their photo.
///
/// The photo loads from `url`. Until it arrives, and if it never does, the
/// avatar draws the fallback instead.
///
/// ```swift
/// Avatar(url: speaker.photoURL, size: AvatarSize.large) {
///     CompanyMark(speaker.company)
/// }
/// ```
///
/// The style clips the avatar to its shape, so a fallback cannot draw outside
/// it.
///
/// Apply `redacted(reason: .placeholder)` to show an avatar whose person is
/// still loading. It then draws a plain shape and asks for no photo.
public struct Avatar<Fallback: View>: View {
    /// The current avatar style.
    @Environment(\.avatarStyle) private var style

    /// The current redaction reasons applied to the view hierarchy.
    @Environment(\.redactionReasons) private var redactionReasons

    /// How far the text size has grown from its default.
    ///
    /// It scales 1 rather than a diameter, because the base size differs per
    /// avatar, so each one multiplies by it.
    @ScaledMetric(relativeTo: .body) private var textScale: CGFloat = 1

    /// Where the photo loads from.
    private let url: URL?

    /// The diameter to draw at, before the text size scales it.
    private let size: AvatarSize

    /// The state to show on the avatar, if any.
    private let status: AvatarStatus?

    /// What to draw instead of the photo.
    private let fallback: Fallback

    /// Creates an avatar that draws `fallback` while its photo is missing.
    ///
    /// - Parameters:
    ///   - url: Where the photo loads from. A `nil` url draws the fallback and
    ///     asks for nothing.
    ///   - size: A diameter from ``AvatarSize``. It grows with the text size,
    ///     then stops. The default is ``AvatarSize/medium``.
    ///   - status: The state to show on the avatar, if any. The style decides
    ///     where it goes.
    ///   - fallback: A content builder that creates what to draw instead of
    ///     the photo.
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

    public var body: some View {
        AnyView(style.makeBody(configuration: configuration))
            .environment(\.avatarDiameter, diameter)
    }

    /// The properties handed to the current avatar style.
    private var configuration: AvatarStyleConfiguration {
        AvatarStyleConfiguration(content: content, size: diameter, status: mark)
    }

    /// The drawn form of the status, if there is one.
    private var mark: AvatarStatusMark? {
        status.map { AvatarStatusMark(status: $0, avatarDiameter: diameter) }
    }

    /// The diameter to draw at, once the text size has scaled it.
    ///
    /// The scaling belongs here rather than to a style, so that every avatar
    /// answers the text size the same way.
    private var diameter: AvatarSize {
        size.scaled(by: min(textScale, Self.largestGrowth))
    }

    /// The largest an avatar grows with the text size.
    ///
    /// Past this an avatar crowds the text beside it out of the row.
    private static var largestGrowth: CGFloat { 1.75 }

    /// The photo, the fallback standing in for it, or a plain shape while the
    /// person loads.
    private var content: some View {
        Group {
            if redactionReasons.contains(.placeholder) {
                // Redaction ignores the clip shape, so draw the plain shape here
                // and ask for no photo.
                Color.secondarySurface
            } else {
                AsyncImage(url: url) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        fallback
                    }
                }
            }
        }
        .accessibilityHidden(true)
    }
}

public extension Avatar where Fallback == AvatarFallback {
    /// Creates an avatar that draws a built-in fallback while its photo is
    /// missing.
    ///
    /// - Parameters:
    ///   - url: Where the photo loads from. A `nil` url draws the fallback and
    ///     asks for nothing.
    ///   - size: A diameter from ``AvatarSize``. It grows with the text size,
    ///     then stops. The default is ``AvatarSize/medium``.
    ///   - status: The state to show on the avatar, if any. The style decides
    ///     where it goes.
    ///   - fallback: What to draw instead of the photo. The default is
    ///     ``AvatarFallback/symbol``.
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
