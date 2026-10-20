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
    }

    /// Where the hero's elements sit, in the hero's own coordinates.
    ///
    /// The darkening places its band from these, so none of it crosses an
    /// element.
    private struct HeroMarks: Equatable {
        /// Where the title's top edge is.
        var titleTop: CGFloat?
    }

    /// The session this hero introduces.
    private let session: SampleSession

    /// How big the page is, or `nil` until it is measured.
    private let page: PageSize?

    /// How far the bars cover the list, or `nil` until they are measured.
    private let bars: BarInsets?

    /// The space from the safe area to the content, shared with the content below the hero.
    private let margin: CGFloat

    /// Whether the screen has a compact or a regular height.
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    /// Whether the screen draws in light or dark mode.
    @Environment(\.colorScheme) private var colorScheme

    /// Whether this person asked for more contrast.
    @Environment(\.colorSchemeContrast) private var contrast

    /// How tall the hero's text block is, or 0 until measured.
    @State private var blockHeight: CGFloat = 0

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
    init(session: SampleSession, page: PageSize?, bars: BarInsets?, margin: CGFloat) {
        self.session = session
        self.page = page
        self.bars = bars
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
            .overlay(alignment: .bottomLeading) { heroBlock }
            .coordinateSpace(Self.heroSpace)
    }
}

// MARK: - Constants

extension SessionHero {
    /// The space the hero's own coordinates are measured in, which moves with the hero as it
    /// scrolls.
    private static let heroSpace = NamedCoordinateSpace.named("sessionHero")

    /// The space above and below the hero's text block.
    private static let heroVerticalMargin: CGFloat = 24

    /// How far the art reaches past the screen's top edge, in points.
    ///
    /// It covers the gap a rounded screen corner or a pull past the top would
    /// otherwise show.
    private static let overscan: CGFloat = 100

    /// The hero's height until the page has been measured.
    private static let unmeasuredHeroHeight: CGFloat = 360

    /// The tallest the hero grows in a tall page, as a share of the page's
    /// height.
    private static let oneColumnHeightShare: CGFloat = 0.75

    /// The height of the hero in a tall page, as a share of its width.
    private static let oneColumnAspect: CGFloat = 1.5

    /// The height of the hero in a wide page, as a share of the page's height.
    private static let wideHeroShare: CGFloat = 0.5

    /// How opaque the tint grows below the band. The art does not show through
    /// it.
    private static let fullDarkening: Double = 1

    /// The length of the band over which the art darkens to the tint, in
    /// points.
    private static let bandLength: CGFloat = 84

    /// How far the band ends above the first line of text, in points.
    private static let bandClearance: CGFloat = 4

    /// How many stops draw the band.
    private static let bandSteps = 16

    /// How opaque the kind line is, against white.
    private static let kindLineOpacity: Double = 0.85

    /// How opaque the facts are, against white.
    private static let supportingTextOpacity: Double = 0.7

    /// The color of text on the hero, in both color schemes.
    private static let onHero = Color.white
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
            darkening
        }
    }

    /// The tint of the session's kind, darker for the contrast setting.
    private var tint: Color {
        session.kind.tint(in: colorScheme, contrast: contrast)
    }
}

// MARK: - Darkening

extension SessionHero {
    /// The tint over the art, clear above a band and full below it.
    ///
    /// The band sits in the empty space above the title.
    private var darkening: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    stops: darkeningStops,
                    startPoint: .top,
                    endPoint: .bottom,
                )
            )
            .ignoresSafeArea(.container, edges: .horizontal)
    }

    /// Where the band ends, just above the title.
    private var bandEnd: CGFloat {
        (marks.titleTop ?? heroHeight / 2) - Self.bandClearance
    }

    /// Where the band starts, which is as far up as the art allows, up to its
    /// full length.
    private var bandStart: CGFloat {
        max(bandEnd - Self.bandLength, -artExtension)
    }

    /// How dark the tint makes the art at a height.
    ///
    /// The tint eases in along the band, with no darkening above it.
    ///
    /// - Parameter height: A height in the hero's coordinates.
    /// - Returns: The opacity of the tint, from 0 to 1.
    private func darkness(at height: CGFloat) -> Double {
        guard bandEnd > bandStart else { return height >= bandEnd ? Self.fullDarkening : 0 }
        let progress = Double(min(max((height - bandStart) / (bandEnd - bandStart), 0), 1))
        let eased = progress * progress * progress * (progress * (progress * 6 - 15) + 10)
        return eased * Self.fullDarkening
    }

    /// The stops of the tint, from the top of the art to the hero's foot.
    private var darkeningStops: [Gradient.Stop] {
        let top = -artExtension
        let span = max(heroHeight - top, 1)
        let band = (0...Self.bandSteps).map {
            bandStart + (bandEnd - bandStart) * CGFloat($0) / CGFloat(Self.bandSteps)
        }
        return ([top, heroHeight] + band).sorted().map { height in
            Gradient.Stop(
                color: tint.opacity(darkness(at: height)),
                location: min(max((height - top) / span, 0), 1),
            )
        }
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
        if isTall {
            return min(page.width * Self.oneColumnAspect, page.height * Self.oneColumnHeightShare)
        }
        return page.height * Self.wideHeroShare
    }
}

// MARK: - Text

extension SessionHero {
    /// The hero's text, at the margin, on the art's lower part.
    private var heroBlock: some View {
        VStack(alignment: .leading, spacing: .medium) {
            heading

            facts
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(Self.onHero)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
        } action: { height in
            blockHeight = height
        }
        .padding(.horizontal, margin)
        .padding(.bottom, Self.heroVerticalMargin)
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
    /// Its top edge is where the first line of text starts.
    private var titleText: some View {
        Text(session.title)
            .font(.title.weight(.bold))
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
            .onGeometryChange(for: CGFloat.self) { proxy in
                proxy.frame(in: Self.heroSpace).minY
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

    /// Returns white at an opacity, or fully white for more contrast.
    ///
    /// - Parameter opacity: How opaque the white is without more contrast.
    /// - Returns: The white, at the opacity or fully opaque.
    private func onHero(_ opacity: Double) -> Color {
        Self.onHero.opacity(contrast == .increased ? 1 : opacity)
    }

    /// The color of the kind line, a light grey.
    private var kindLineText: Color {
        onHero(Self.kindLineOpacity)
    }

    /// The color of the facts, grey.
    private var supportingText: Color {
        onHero(Self.supportingTextOpacity)
    }

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
            Text("\(Image(icon: .calendar))\u{00A0}\(session.dayLabel)")
            Text("\(Image(icon: .clock))\u{00A0}\(session.time)")
            Text("\(Image(icon: .location))\u{00A0}\(session.room)")
        }
        .fixedSize()
    }
}
