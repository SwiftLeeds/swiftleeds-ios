import SwiftUI
import UIDesign

/// A view that introduces a session with its art, title and facts.
struct SessionHero: View {
    /// How far the bars cover the list.
    struct BarInsets: Equatable {
        /// The height of the bar over the top of the content.
        let top: CGFloat

        /// The height of the tab bar over the bottom of the content.
        let bottom: CGFloat
    }

    /// The size of the page the hero fits into.
    struct PageSize: Equatable {
        /// The width of the scroll view inside the safe area.
        let width: CGFloat

        /// The height of the screen the scroll view fills, bars included.
        let height: CGFloat

        /// Returns the width inside a margin on each side.
        ///
        /// - Parameter margin: The margin on each side, in points.
        /// - Returns: The width left inside the margins.
        func contentWidth(margin: CGFloat) -> CGFloat {
            width - 2 * margin
        }
    }

    /// Where the hero's elements sit, in the hero's own coordinates.
    ///
    /// The darkening places its band from these, so none of it crosses an
    /// element.
    struct HeroMarks: Equatable {
        /// Where the chip's top edge is, or `nil` without a chip.
        var chipTop: CGFloat?

        /// Where the title's top edge is.
        var titleTop: CGFloat?
    }

    /// How the hero's text is arranged, decided by the width measured.
    enum HeroLayout: Equatable {
        /// One column of text.
        case oneColumn

        /// A wide column of text beside a narrow one of actions and credits.
        case twoColumns
    }

    /// Where the title's top edge sits, so two columns can line up on it.
    private enum TitleTopAlignment: AlignmentID {
        /// The top of the view, unless the view moves it.
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[.top]
        }
    }

    /// The session this hero introduces.
    private let session: SampleSession

    /// How big the page is, or `nil` until it is measured.
    private let page: PageSize?

    /// How far the bars cover the list, or `nil` until they are measured.
    private let bars: BarInsets?

    /// The space from the safe area to the content, shared with the content below the hero.
    private let margin: CGFloat

    /// Where a person is in the session's day.
    private let moment: SessionMoment

    /// The action that shows a speaker's page.
    private let showSpeaker: (SamplePerson) -> Void

    /// Whether this person favorited the session.
    @Binding private var isFavorite: Bool

    /// Whether the screen has a compact or a regular height.
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    /// Whether the screen draws in light or dark mode.
    @Environment(\.colorScheme) private var colorScheme

    /// Whether this person asked for more contrast.
    @Environment(\.colorSchemeContrast) private var contrast

    /// The text size this person chose.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// The height of the capsule and the size of the star, which grow with the text.
    @ScaledMetric(relativeTo: .headline)
    private var actionHeight: CGFloat = HeroActions.actionHeightAtDefaultSize

    /// The content width from which two columns fit, which grows with the text.
    @ScaledMetric(relativeTo: .body) private var twoColumnThreshold: CGFloat = twoColumnWidth

    /// How tall the hero's text block is, or 0 until measured.
    @State private var blockHeight: CGFloat = 0

    /// The capsule's width on one line, padding included, in points, or `nil` until measured.
    @State private var capsuleWidth: CGFloat?

    /// Where the hero's elements sit, as far as they are measured.
    @State private var marks = HeroMarks()

    /// Creates a hero for one session.
    ///
    /// - Parameters:
    ///   - session: The session this hero introduces.
    ///   - page: The size of the page the hero fits into, or `nil` until it is measured. The
    ///     hero then uses its fallback height.
    ///   - bars: How far the bars cover the list, or `nil` until they are measured. The hero then
    ///     uses a bar height of 0.
    ///   - margin: The space from the safe area to the content, shared with the content below the
    ///     hero.
    ///   - moment: Where a person is in the session's day. It decides the chip above the title
    ///     and the capsule beside the star.
    ///   - showSpeaker: The action that shows a speaker's page. A tap on a credited name runs it.
    ///   - isFavorite: Whether this person favorited the session. The star changes it.
    init(
        session: SampleSession,
        page: PageSize?,
        bars: BarInsets?,
        margin: CGFloat,
        moment: SessionMoment,
        showSpeaker: @escaping (SamplePerson) -> Void,
        isFavorite: Binding<Bool>,
    ) {
        self.session = session
        self.page = page
        self.bars = bars
        self.moment = moment
        self.showSpeaker = showSpeaker
        _isFavorite = isFavorite
        // A bare CGFloat, not a Spacing token: UIDesign's Spacing has no 20-point value, and the
        // gallery cannot make one, because Spacing's initializer is internal to UIDesign.
        self.margin = margin
    }

    /// The art under the bar, darkened under the text, with the text on it.
    ///
    /// The hero ends on a hard edge into the page.
    var body: some View {
        Color.clear
            .frame(height: heroHeight)
            .background(alignment: .top) {
                backdrop
                    .padding(.top, -artExtension)
            }
            .overlay(alignment: .bottomLeading) { text }
            .coordinateSpace(Self.heroSpace)
    }
}

// MARK: - Constants

extension SessionHero {
    /// The space the hero's own coordinates are measured in, which moves with the hero as it
    /// scrolls.
    static let heroSpace = NamedCoordinateSpace.named("sessionHero")

    /// The alignment that lines columns up on the title's top edge.
    static let titleTop = VerticalAlignment(TitleTopAlignment.self)

    /// The space between the two columns, in points.
    static let columnGap: CGFloat = 32

    /// The space above and below the hero's text block.
    private static let heroVerticalMargin: CGFloat = 24

    /// How far the art reaches past the screen's top edge, in points.
    ///
    /// It covers the gap a rounded screen corner or a pull past the top would
    /// otherwise show.
    private static let overscan: CGFloat = 100

    /// The hero's height until the page has been measured.
    private static let unmeasuredHeroHeight: CGFloat = 360

    /// The content width from which the hero uses two columns, at the default text size.
    private static let twoColumnWidth: CGFloat = 576

    /// The narrowest the trailing column grows, in points.
    private static let trailingColumnMinimum: CGFloat = 264

    /// The share of the content width the trailing column takes, at the least.
    private static let trailingColumnShare: CGFloat = 0.3

    /// The tallest a one-column hero grows in a tall page, as a share of the page's
    /// height.
    private static let oneColumnHeightShare: CGFloat = 0.75

    /// The height of a one-column hero in a tall page, as a share of its width.
    private static let oneColumnAspect: CGFloat = 1.5

    /// The height of a two-column hero in a tall page, as a share of the page's height.
    private static let tallHeroShare: CGFloat = 0.6

    /// The height of a hero in a wide page, as a share of the page's height.
    private static let wideHeroShare: CGFloat = 0.5

    /// The color of text on the hero, in both color schemes.
    static let onHero = Color.white
}

// MARK: - Art

extension SessionHero {
    /// The height of the bar over the top of the hero, or 0 until known.
    private var barHeight: CGFloat {
        bars?.top ?? 0
    }

    /// How far the art reaches above the hero's top edge, under the bar and past the screen's
    /// edge.
    private var artExtension: CGFloat {
        barHeight + Self.overscan
    }

    /// The art, with the darkening over its lower part.
    private var backdrop: some View {
        KindArtwork(
            kind: session.kind,
            topInset: artExtension,
            bottomInset: blockHeight + Self.heroVerticalMargin,
        )
        .overlay {
            HeroDarkening(
                tint: tint,
                chipTop: marks.chipTop,
                titleTop: marks.titleTop,
                heroHeight: heroHeight,
                artExtension: artExtension,
            )
        }
    }

    /// The tint of the session's kind, darker for the contrast setting.
    private var tint: Color {
        session.kind.tint(in: colorScheme, contrast: contrast)
    }
}

// MARK: - Height

extension SessionHero {
    /// How tall the hero stands below the bar.
    private var heroHeight: CGFloat {
        guard let page else { return Self.unmeasuredHeroHeight }
        return max(neededHeight, wantedHeight(in: page)) - barHeight
    }

    /// The least the hero stands, bar included, so the text block fits with
    /// its margins and clears the tab bar where the hero would meet it.
    private var neededHeight: CGFloat {
        let fitted = barHeight + blockHeight + 2 * Self.heroVerticalMargin
        guard let page, let bars else { return fitted }
        let meetsTabBar = fitted > page.height - bars.bottom
        return meetsTabBar ? fitted + bars.bottom : fitted
    }

    /// The height the hero would like, bar included, in a page.
    ///
    /// - Parameter page: The page the hero fits into.
    /// - Returns: The height the hero would like, in points.
    private func wantedHeight(in page: PageSize) -> CGFloat {
        if verticalSizeClass == .compact {
            // The block and its margins, so a strip of the page shows below.
            return neededHeight
        }
        let isTall = page.height > page.width
        switch (layout, isTall) {
        case (.oneColumn, true):
            return min(page.width * Self.oneColumnAspect, page.height * Self.oneColumnHeightShare)
        case (.twoColumns, true):
            return page.height * Self.tallHeroShare
        case (.oneColumn, false):
            return page.height * Self.wideHeroShare
        case (.twoColumns, false):
            return page.height * Self.wideHeroShare
        }
    }
}

// MARK: - Layout

extension SessionHero {
    /// How the hero's text is arranged, from the width measured.
    ///
    /// Two columns need the content to reach the threshold, and the capsule and the star to fit
    /// side by side in the trailing column. An accessibility text size always uses one column, and
    /// so does the hero until the page and the capsule are measured.
    private var layout: HeroLayout {
        guard let page, !dynamicTypeSize.isAccessibilitySize else { return .oneColumn }
        let fitsWidth = page.contentWidth(margin: margin) >= twoColumnThreshold
        let fitsActions = HeroActions.fitsBeside(
            in: trailingColumnWidth,
            moment: moment,
            capsuleWidth: capsuleWidth,
            actionHeight: actionHeight,
        )
        return fitsWidth && fitsActions ? .twoColumns : .oneColumn
    }

    /// The width of the trailing column of a two-column hero, in points.
    private var trailingColumnWidth: CGFloat {
        guard let page else { return Self.trailingColumnMinimum }
        let share = page.contentWidth(margin: margin) * Self.trailingColumnShare
        return max(Self.trailingColumnMinimum, share)
    }

    /// The width of the leading column of a two-column hero, in points, or 0 until the page is
    /// measured.
    private var leadingColumnWidth: CGFloat {
        guard let page else { return 0 }
        return page.contentWidth(margin: margin) - Self.columnGap - trailingColumnWidth
    }
}

// MARK: - Text

extension SessionHero {
    /// The hero's text, at the margin, on the art's lower part.
    private var text: some View {
        HeroBlock(
            session: session,
            moment: moment,
            columns: layout,
            availableWidth: page.map { $0.contentWidth(margin: margin) },
            leadingColumnWidth: leadingColumnWidth,
            trailingColumnWidth: trailingColumnWidth,
            showSpeaker: showSpeaker,
            isFavorite: $isFavorite,
            capsuleWidth: $capsuleWidth,
            marks: $marks,
            height: $blockHeight,
        )
        .padding(.horizontal, margin)
        .padding(.bottom, Self.heroVerticalMargin)
    }
}
