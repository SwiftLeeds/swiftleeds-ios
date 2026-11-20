import SwiftUI

/// A view that shows a short word in a small capsule.
///
/// A badge appears beside a title in a list row or a heading. It labels a subject
/// with a word such as "Workshop" or "New".
///
/// You create a badge with a title.
///
/// ```swift
/// let layout = dynamicTypeSize.isAccessibilitySize
///     ? AnyLayout(VStackLayout(alignment: .leading))
///     : AnyLayout(HStackLayout(alignment: .firstTextBaseline))
/// layout {
///     Text(session.title)
///     Badge("Workshop")
///         .badgePalette(.teal)
/// }
/// ```
///
/// To draw an icon before the word, pass one.
///
/// ```swift
/// Badge("Workshop", icon: Icon(.hammerFill))
/// ```
///
/// The built-in styles keep the icon beside the word, even when a parent sets a
/// label style. To change the look, set a custom ``BadgeStyle``.
///
/// VoiceOver reads the word and skips the icon.
///
/// A badge is neutral until a ``BadgePalette`` says otherwise. The palette comes
/// from the environment, so one modifier on a stack colors every badge in it.
///
/// ```swift
/// VStack {
///     Badge("Workshop")
///     Badge("Talk")
/// }
/// .badgePalette(.violet)
/// ```
///
/// A badge is essential content, so it grows with the text size. The word carries
/// the meaning. The capsule's color only supports it, so choose a word that reads
/// the same without color.
///
/// A badge keeps to one line and ends a long title with "…". VoiceOver reads the
/// whole title, so keep badge words short.
public struct Badge<Label: View>: View {
    /// Where a badge takes its colors from.
    private enum Source {
        /// The palette set in the environment.
        case palette
        /// A status, which ignores the palette.
        case status(BadgeStatus)
    }

    /// A view that draws a badge in a given style.
    private struct ResolvedBadgeStyle<Style: BadgeStyle>: View {
        /// The style that draws the badge.
        let style: Style

        /// The properties of the badge.
        let configuration: BadgeStyleConfiguration

        var body: some View {
            style.makeBody(configuration: configuration)
        }
    }

    /// The current badge style.
    @Environment(\.badgeStyle) private var style

    /// The current badge palette.
    @Environment(\.badgePalette) private var palette

    /// The content of the badge.
    private let label: Label

    /// Where the badge takes its colors from.
    private let source: Source

    /// Creates a badge with a custom label.
    ///
    /// - Parameter label: A content builder that creates the badge's label.
    public init(@ViewBuilder label: () -> Label) {
        self.label = label()
        source = .palette
    }

    /// Creates a badge that draws the colors of a status.
    ///
    /// - Parameters:
    ///   - status: The status whose colors the badge draws.
    ///   - label: A content builder that creates the badge's label.
    init(status: BadgeStatus, @ViewBuilder label: () -> Label) {
        self.label = label()
        source = .status(status)
    }

    public var body: some View {
        AnyView(resolved(in: style))
    }

    /// The properties handed to the current badge style.
    private var configuration: BadgeStyleConfiguration {
        BadgeStyleConfiguration(label: label, colors: colors)
    }

    /// The colors the badge draws with, from its status or else the environment palette.
    private var colors: ColorFamily {
        switch source {
        case .palette: palette.colors
        case .status(let status): status.colors
        }
    }

    /// Returns a view that draws the badge in the given style.
    ///
    /// - Parameter style: The style to draw the badge in.
    /// - Returns: A view that draws the badge in `style`.
    private func resolved(in style: some BadgeStyle) -> some View {
        ResolvedBadgeStyle(style: style, configuration: configuration)
    }
}

#Preview("Short title") {
    Badge("Workshop")
        .padding(.lg)
}

#Preview("Palettes") {
    VStack(alignment: .leading, spacing: .md) {
        Badge("Neutral").badgePalette(.neutral)
        Badge("Blue").badgePalette(.blue)
        Badge("Teal").badgePalette(.teal)
        Badge("Violet").badgePalette(.violet)
        Badge("Raspberry").badgePalette(.raspberry)
        Badge("Sponsor").badgePalette(.sponsor)
    }
    .padding(.lg)
}

#Preview("Statuses") {
    VStack(alignment: .leading, spacing: .md) {
        Badge("Confirmed", status: .success)
        Badge("Few seats", status: .warning)
        Badge("Cancelled", status: .error)
        Badge("New", status: .info)
    }
    .padding(.lg)
}

#Preview("Loading") {
    VStack(alignment: .leading, spacing: .md) {
        Badge("Workshop")
        Badge("Workshop", icon: Icon(.hammerFill)).badgePalette(.teal)
        Badge("Cancelled", status: .error)
    }
    .redacted(reason: .placeholder)
    .padding(.lg)
}

#Preview("Filled") {
    VStack(alignment: .leading, spacing: .md) {
        Badge("Live", status: .error)
        Badge("Workshop", icon: Icon(.hammerFill)).badgePalette(.teal)
    }
    .badgeStyle(.filled)
    .padding(.lg)
}

#Preview("Icons") {
    VStack(alignment: .leading, spacing: .md) {
        Badge("Workshop", icon: Icon(.hammerFill))
        Badge("Workshop", icon: Icon(.hammerFill)).badgePalette(.teal)
    }
    .padding(.lg)
}

#Preview("Long title") {
    Badge("Fully booked, join the waiting list")
        .frame(width: 160)
        .padding(.lg)
}
