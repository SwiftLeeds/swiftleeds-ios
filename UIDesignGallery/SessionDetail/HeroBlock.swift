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

    /// The width the block's content has, or `nil` until the page is measured.
    private let availableWidth: CGFloat?

    /// Whether this person favorited the session.
    @Binding private var isFavorite: Bool

    /// Where the chip and the title sit, in the hero's coordinates.
    @Binding private var marks: SessionHero.HeroMarks

    /// How tall the block is.
    @Binding private var height: CGFloat

    /// Whether this person asked for more contrast.
    @Environment(\.colorSchemeContrast) private var contrast

    /// Creates a block for one session.
    ///
    /// - Parameters:
    ///   - session: The session this block introduces.
    ///   - moment: Where a person is in the session's day. It decides the chip above the title and
    ///     the capsule beside the star.
    ///   - availableWidth: The width the block's content has, or `nil` until the page is measured.
    ///   - isFavorite: Whether this person favorited the session. The star changes it.
    ///   - marks: Where the chip and the title sit, in the hero's coordinates. The block writes it.
    ///   - height: How tall the block is. The block writes it.
    init(
        session: SampleSession,
        moment: SessionMoment,
        availableWidth: CGFloat?,
        isFavorite: Binding<Bool>,
        marks: Binding<SessionHero.HeroMarks>,
        height: Binding<CGFloat>,
    ) {
        self.session = session
        self.moment = moment
        self.availableWidth = availableWidth
        _isFavorite = isFavorite
        _marks = marks
        _height = height
    }

    /// The chip and heading, the actions and the facts, at the leading edge.
    var body: some View {
        VStack(alignment: .leading, spacing: .medium) {
            chipAndHeading

            HeroActions(
                moment: moment,
                isFavorite: $isFavorite,
                availableWidth: availableWidth,
            )

            facts
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

    /// The color of the facts, grey.
    private var supportingText: Color {
        onHero(Self.supportingTextOpacity)
    }
}

// MARK: - Facts

extension HeroBlock {
    /// When and where the session runs, side by side while they fit.
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

    /// The day, the time range and the room, each led by its symbol.
    ///
    /// A no-break space keeps each symbol with its words.
    private var factTexts: some View {
        Group {
            Text("\(Image(icon: .calendar))\u{00A0}\(session.dayLabel(now: moment.now(for: session)))")
            Text("\(Image(icon: .clock))\u{00A0}\(session.time)")
            Text("\(Image(icon: .location))\u{00A0}\(session.room)")
        }
        .fixedSize()
    }
}
