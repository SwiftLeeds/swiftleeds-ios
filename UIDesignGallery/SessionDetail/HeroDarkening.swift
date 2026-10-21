import SwiftUI

/// A view that tints the art from a band over the hero's text down to the hero's foot.
///
/// The art above the band shows untouched. The band sits in the empty space above the chip, or
/// above the title without one.
struct HeroDarkening: View {
    /// The color the art darkens to.
    private let tint: Color

    /// Where the chip's top edge is in the hero's coordinates, or `nil` without a chip.
    private let chipTop: CGFloat?

    /// Where the title's top edge is in the hero's coordinates, or `nil` until it is measured.
    private let titleTop: CGFloat?

    /// How tall the hero stands below the bar, in points.
    private let heroHeight: CGFloat

    /// How far the art reaches above the hero's top edge, in points.
    private let artExtension: CGFloat

    /// Creates the darkening for one hero.
    ///
    /// - Parameters:
    ///   - tint: The color the art darkens to.
    ///   - chipTop: Where the chip's top edge is in the hero's coordinates, or `nil` without a
    ///     chip. The band then ends above the title.
    ///   - titleTop: Where the title's top edge is in the hero's coordinates, or `nil` until it is
    ///     measured. The band then ends above the middle of the hero.
    ///   - heroHeight: How tall the hero stands below the bar, in points.
    ///   - artExtension: How far the art reaches above the hero's top edge, in points.
    init(tint: Color, chipTop: CGFloat?, titleTop: CGFloat?, heroHeight: CGFloat, artExtension: CGFloat) {
        self.tint = tint
        self.chipTop = chipTop
        self.titleTop = titleTop
        self.heroHeight = heroHeight
        self.artExtension = artExtension
    }

    /// The tint, clear above the band and full below it.
    var body: some View {
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
}

// MARK: - Constants

extension HeroDarkening {
    /// How opaque the tint grows below the band. The art does not show through it.
    private static let fullDarkening: Double = 1

    /// The length of the band over which the art darkens to the tint, in points.
    private static let bandLength: CGFloat = 84

    /// How far the band ends above the first line of text, in points.
    private static let bandClearance: CGFloat = 4

    /// How many stops draw the band.
    private static let bandSteps = 16
}

// MARK: - Band

extension HeroDarkening {
    /// Where the band ends, just above the first line of text.
    private var bandEnd: CGFloat {
        (chipTop ?? titleTop ?? heroHeight / 2) - Self.bandClearance
    }

    /// Where the band starts, which is as far up as the art allows, up to its full length.
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
