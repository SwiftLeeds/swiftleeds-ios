import SwiftUI
import UIDesign

/// A view that holds the text and actions drawn on a session hero's art.
///
/// It reports where its chip and title sit, and how tall it is, so the art can darken under it.
struct HeroBlock: View {
    /// The session this block introduces.
    private let session: SampleSession

    /// Where a person is in the session's day.
    private let moment: SessionMoment

    /// How the block arranges its text, in one column or two.
    private let columns: SessionHero.HeroLayout

    /// The width the block's content has, or `nil` until the page is measured.
    private let availableWidth: CGFloat?

    /// The width of the leading column in two columns, in points.
    private let leadingColumnWidth: CGFloat

    /// The width of the trailing column in two columns, in points.
    private let trailingColumnWidth: CGFloat

    /// The action that shows a speaker's page.
    private let showSpeaker: (SamplePerson) -> Void

    /// Whether this person favorited the session.
    @Binding private var isFavorite: Bool

    /// The capsule's width on one line, in points, or `nil` until measured.
    @Binding private var capsuleWidth: CGFloat?

    /// Where the chip and the title sit, in the hero's coordinates.
    @Binding private var marks: SessionHero.HeroMarks

    /// How tall the block is.
    @Binding private var height: CGFloat

    /// Whether this person asked for more contrast.
    @Environment(\.colorSchemeContrast) private var contrast

    /// How many pixels make one point on this screen.
    @Environment(\.displayScale) private var displayScale

    /// Creates a block for one session.
    ///
    /// - Parameters:
    ///   - session: The session this block introduces.
    ///   - moment: Where a person is in the session's day. It decides the chip above the title and
    ///     the capsule beside the star.
    ///   - columns: How the block arranges its text. Two columns need the leading and trailing
    ///     column widths.
    ///   - availableWidth: The width the block's content has, or `nil` until the page is measured.
    ///   - leadingColumnWidth: The width of the leading column in two columns, in points.
    ///   - trailingColumnWidth: The width of the trailing column in two columns, in points.
    ///   - showSpeaker: The action that shows a speaker's page. A tap on a credited name runs it.
    ///   - isFavorite: Whether this person favorited the session. The star changes it.
    ///   - capsuleWidth: The capsule's width on one line, in points, or `nil` until measured. The
    ///     block writes it.
    ///   - marks: Where the chip and the title sit, in the hero's coordinates. The block writes it.
    ///   - height: How tall the block is. The block writes it.
    init(
        session: SampleSession,
        moment: SessionMoment,
        columns: SessionHero.HeroLayout,
        availableWidth: CGFloat?,
        leadingColumnWidth: CGFloat,
        trailingColumnWidth: CGFloat,
        showSpeaker: @escaping (SamplePerson) -> Void,
        isFavorite: Binding<Bool>,
        capsuleWidth: Binding<CGFloat?>,
        marks: Binding<SessionHero.HeroMarks>,
        height: Binding<CGFloat>,
    ) {
        self.session = session
        self.moment = moment
        self.columns = columns
        self.availableWidth = availableWidth
        self.leadingColumnWidth = leadingColumnWidth
        self.trailingColumnWidth = trailingColumnWidth
        self.showSpeaker = showSpeaker
        _isFavorite = isFavorite
        _capsuleWidth = capsuleWidth
        _marks = marks
        _height = height
    }

    /// The block's content in one column or two, at the leading edge.
    var body: some View {
        Group {
            switch columns {
            case .oneColumn: oneColumnBlock
            case .twoColumns: twoColumnBlock
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(SessionHero.onHero)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
        } action: { newHeight in
            height = newHeight
        }
    }
}

// MARK: - Constants

extension HeroBlock {
    /// How opaque the black behind the chip is.
    private static let chipOpacity: Double = 0.5

    /// How opaque the kind line is, against white.
    private static let kindLineOpacity: Double = 0.85

    /// How opaque the facts are, against white.
    private static let supportingTextOpacity: Double = 0.7

    /// The most lines the teaser takes.
    private static let teaserLines = 2

    /// How opaque the divider is, against white.
    private static let dividerOpacity: Double = 0.25

    /// How opaque the divider is, against white, with more contrast.
    private static let increasedDividerOpacity: Double = 0.5
}

// MARK: - Columns

extension HeroBlock {
    /// The chip and heading, the actions, a divider, the teaser, the credits and the facts, in
    /// one column.
    private var oneColumnBlock: some View {
        VStack(alignment: .leading, spacing: .medium) {
            chipAndHeading

            actions

            divider

            teaserText

            credits

            facts
        }
    }

    /// The leading column of chip, title, kind line, teaser and facts, beside the trailing column
    /// of the actions and the credits.
    ///
    /// The columns share rows, so the credits' first line sits on the baseline of the teaser's
    /// first line.
    private var twoColumnBlock: some View {
        Grid(
            alignment: .leading,
            horizontalSpacing: SessionHero.columnGap,
            verticalSpacing: CGFloat(Spacing.medium),
        ) {
            // An HStack, not a GridRow: a GridRow with a custom vertical alignment leaves the
            // alignment offset out of the row's height, so the stacked star overlapped the divider.
            HStack(alignment: SessionHero.titleTop, spacing: SessionHero.columnGap) {
                chipAndHeading
                    .frame(width: leadingColumnWidth, alignment: .leading)

                actions
                    .frame(width: trailingColumnWidth, alignment: .leading)
                    .alignmentGuide(SessionHero.titleTop) { dimensions in
                        dimensions[.top]
                    }
            }

            GridRow {
                divider
                    .gridCellColumns(2)
            }

            GridRow(alignment: .firstTextBaseline) {
                teaserText
                    .frame(width: leadingColumnWidth, alignment: .leading)

                credits
                    .frame(width: trailingColumnWidth, alignment: .leading)
            }

            GridRow {
                facts
                    .frame(width: leadingColumnWidth, alignment: .leading)
            }
        }
    }

    /// The width the capsule and the star share, or `nil` until the page is measured.
    private var actionsWidth: CGFloat? {
        switch columns {
        case .oneColumn: availableWidth
        case .twoColumns: trailingColumnWidth
        }
    }

    /// The capsule that suits the moment, with the star beside it or under it.
    private var actions: some View {
        HeroActions(
            moment: moment,
            columns: columns,
            isFavorite: $isFavorite,
            availableWidth: actionsWidth,
            capsuleWidth: $capsuleWidth,
        )
    }

    /// The credited names, in the teaser's text style.
    private var credits: some View {
        HeroCredits(
            kind: session.kind,
            speakers: session.lineup.credited,
            leadColor: supportingText,
            showSpeaker: showSpeaker,
        )
    }
}

// MARK: - Heading

extension HeroBlock {
    /// The chip over the title and kind line, close together.
    private var chipAndHeading: some View {
        VStack(alignment: .leading, spacing: .small) {
            chip

            heading
        }
    }

    /// The chip that says where the session is in its day, or nothing once it is over.
    ///
    /// Its top edge is where the first line of text starts.
    @ViewBuilder
    private var chip: some View {
        if let text = moment.chipText(for: session) {
            Text(text)
                .font(.caption.weight(.semibold))
                .foregroundStyle(SessionHero.onHero)
                .padding(.horizontal, .small)
                .padding(.vertical, .xSmall)
                .background(Color.black.opacity(Self.chipOpacity), in: .capsule)
                .onGeometryChange(for: CGFloat.self) { proxy in
                    proxy.frame(in: SessionHero.heroSpace).minY
                } action: { top in
                    marks.chipTop = top
                }
        }
    }

    /// The title, with the session's kind and length under it.
    private var heading: some View {
        VStack(alignment: .leading, spacing: .xSmall) {
            titleText

            kindLine
        }
        .multilineTextAlignment(.leading)
    }

    /// What the session is called.
    ///
    /// With no chip, its top edge is where the first line of text starts.
    private var titleText: some View {
        Text(session.title)
            .font(.title.weight(.bold))
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
            .alignmentGuide(SessionHero.titleTop) { dimensions in
                dimensions[.top]
            }
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.frame(in: SessionHero.heroSpace).minY
            } action: { top in
                marks.titleTop = top
            }
    }

    /// The session's kind and how long it runs.
    private var kindLine: some View {
        let length = session.duration.formatted(
            .units(allowed: [.minutes], width: .abbreviated)
        )
        return Text("\(session.kind.displayName) \u{00B7} \(length)")
            .font(.subheadline.weight(.medium))
            .monospacedDigit()
            .foregroundStyle(kindLineText)
    }
}

// MARK: - Teaser

extension HeroBlock {
    /// A thin line across the block's width, between the actions and the teaser.
    private var divider: some View {
        let opacity = contrast == .increased ? Self.increasedDividerOpacity : Self.dividerOpacity
        return Rectangle()
            .fill(SessionHero.onHero.opacity(opacity))
            .frame(height: 1 / displayScale)
            .accessibilityHidden(true)
    }

    /// The session's short summary, two lines at most.
    private var teaserText: some View {
        Text(session.teaser)
            .font(.subheadline)
            .foregroundStyle(supportingText)
            .lineLimit(Self.teaserLines)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Colors

extension HeroBlock {
    /// Returns white at an opacity, or fully white for more contrast.
    ///
    /// - Parameter opacity: How opaque the white is without more contrast.
    /// - Returns: The white, at the opacity or fully opaque.
    private func onHero(_ opacity: Double) -> Color {
        SessionHero.onHero.opacity(contrast == .increased ? 1 : opacity)
    }

    /// The color of the kind line, a light grey.
    private var kindLineText: Color {
        onHero(Self.kindLineOpacity)
    }

    /// The color of the teaser, the facts and the credits' lead word, grey.
    private var supportingText: Color {
        onHero(Self.supportingTextOpacity)
    }
}

// MARK: - Facts

extension HeroBlock {
    /// When the session runs, and where if not the main room, side by side while they fit.
    ///
    /// Each fact is its own text, so a large text size stacks the facts
    /// rather than breaking one across lines, and the row mirrors
    /// right-to-left.
    private var facts: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: .medium) {
                factTexts
            }

            VStack(alignment: .leading, spacing: .xSmall) {
                factTexts
            }
        }
        .font(.subheadline)
        .monospacedDigit()
        .foregroundStyle(supportingText)
    }

    /// The day, the time range and, outside the main room, the room, each led by its symbol.
    ///
    /// A no-break space keeps each symbol with its words.
    private var factTexts: some View {
        Group {
            Text("\(Image(icon: .calendar))\u{00A0}\(session.dayLabel(now: moment.now(for: session)))")
            Text("\(Image(icon: .clock))\u{00A0}\(session.time)")
            if !session.isInMainRoom {
                Text("\(Image(icon: .location))\u{00A0}\(session.room)")
            }
        }
        .fixedSize()
    }
}
