import SwiftUI
import UIDesign

/// A view that stands in for the `Badge` component's role appearance.
///
/// A conference role takes the colors its halo runs between, so the word and
/// the ring read as one thing. A ticket role takes its own color as the text,
/// with a symbol beside it, on a pale tint of the same color. Neither takes a
/// flat status color: a filled capsule is the shape a status already uses, and
/// green, amber and purple are spoken for.
struct MockRoleBadge: View {
    /// The standing this badge names, and how it is drawn.
    private enum Source: Equatable {
        /// A standing drawn in the colors of its halo.
        case conference(ConferenceRole)

        /// A standing drawn in its ticket's color, with its symbol.
        case ticket(TicketRole)
    }

    /// The standing this badge names, and how it is drawn.
    private let source: Source

    /// How faint the fill is against the text, for a conference role.
    private static let fillOpacity: Double = 0.18

    /// How faint the fill is against the text, for a ticket role.
    private static let ticketFillOpacity: Double = 0.14

    /// How much white a ticket role's color takes in dark mode, so it reads on
    /// a dark page.
    private static let darkLightening: Double = 0.45

    /// How faint the fill is against the text, for a ticket role in dark mode.
    private static let darkFillOpacity: Double = 0.18

    /// The space either side of the badge's content, which grows with the text.
    @ScaledMetric(relativeTo: .caption)
    private var horizontalPadding = CGFloat(Spacing.small)

    /// The space above and below the badge's content, which grows with the
    /// text.
    @ScaledMetric(relativeTo: .caption)
    private var verticalPadding = CGFloat(Spacing.xxSmall)

    /// Whether the screen is light or dark.
    @Environment(\.colorScheme) private var colorScheme

    /// Creates a badge that names a standing in the colors of its halo.
    ///
    /// - Parameter role: The standing this badge names.
    init(role: ConferenceRole) {
        source = .conference(role)
    }

    /// Creates a badge that names a standing in its ticket's color.
    ///
    /// - Parameter role: The standing this badge names.
    init(role: TicketRole) {
        source = .ticket(role)
    }

    var body: some View {
        switch source {
        case .conference(let role): conferenceBadge(role)
        case .ticket(let role): ticketBadge(role)
        }
    }

    /// Returns a badge drawn between the colors of a halo.
    ///
    /// - Parameter role: The standing the badge names.
    private func conferenceBadge(_ role: ConferenceRole) -> some View {
        let colors = LinearGradient(
            colors: role.colors,
            startPoint: .leading,
            endPoint: .trailing,
        )
        return Text(role.name)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.textPrimary)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(colors.opacity(Self.fillOpacity), in: .capsule)
            .overlay {
                Capsule().strokeBorder(colors, lineWidth: CGFloat(BorderWidth.thin))
            }
    }

    /// Returns a badge drawn in a ticket's color, with its symbol.
    ///
    /// - Parameter role: The standing the badge names.
    private func ticketBadge(_ role: TicketRole) -> some View {
        let isDark = colorScheme == .dark
        let color = isDark ? role.color.mix(with: .white, by: Self.darkLightening) : role.color
        let fill = isDark ? Self.darkFillOpacity : Self.ticketFillOpacity
        return HStack(spacing: .xSmall) {
            Image(systemName: role.symbol)
                .accessibilityHidden(true)

            Text(role.name)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(color)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(color.opacity(fill), in: .capsule)
    }
}
