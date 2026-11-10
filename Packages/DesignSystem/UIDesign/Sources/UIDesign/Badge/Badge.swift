import SwiftUI

/// A view that shows a short word in a small capsule.
///
/// A badge appears beside a title in a list row or a heading. It labels a subject
/// with a word such as "Workshop" or "New".
///
/// You create a badge with a title.
///
/// ```swift
/// HStack {
///     Text(session.title)
///     Badge("Workshop")
///         .badgePalette(.teal)
/// }
/// ```
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
/// A long title wraps onto more lines. To keep a badge on one line, apply
/// `lineLimit(_:)` to it.
public struct Badge<Label: View>: View {
    /// The current badge style.
    @Environment(\.badgeStyle) private var style

    /// The current badge palette.
    @Environment(\.badgePalette) private var palette

    /// The content of the badge.
    private let label: Label

    /// Creates a badge with a custom label.
    ///
    /// - Parameter label: A content builder that creates the badge's label.
    public init(@ViewBuilder label: () -> Label) {
        self.label = label()
    }

    public var body: some View {
        AnyView(style.makeBody(configuration: configuration))
    }

    /// The properties handed to the current badge style.
    private var configuration: BadgeStyleConfiguration {
        BadgeStyleConfiguration(label: label, colors: palette.colors)
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

#Preview("Long title") {
    Badge("Fully booked, join the waiting list")
        .frame(width: 160)
        .padding(.lg)
}
