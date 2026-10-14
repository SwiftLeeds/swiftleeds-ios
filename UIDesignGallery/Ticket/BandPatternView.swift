import SwiftUI

/// A view that draws a pattern in faint white across its whole area.
///
/// The pattern is decoration. The label on top keeps its own contrast.
/// When the person turns on Differentiate Without Color, the pattern gets
/// bolder, so the roles tell apart in greyscale at a glance.
struct BandPatternView: View {
    /// The pattern to draw.
    let pattern: BandPattern

    /// Whether the person asked the system to differentiate without color.
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    /// How strong the white is.
    private static let opacity: Double = 0.08

    /// How strong the white is when the person differentiates without color.
    private static let boldOpacity: Double = 0.20

    /// The distance between the lines or stripes.
    private static let gap: CGFloat = 12

    /// The width of a line or a stripe.
    private static let lineWidth: CGFloat = 3

    /// The width of a line or a stripe when the person differentiates without color.
    private static let boldLineWidth: CGFloat = 4

    /// The radius of a dot.
    private static let dotRadius: CGFloat = 2.5

    /// The radius of a dot when the person differentiates without color.
    private static let boldDotRadius: CGFloat = 3.5

    /// The distance between the centers of two dots.
    private static let dotGap: CGFloat = 14

    /// The strength of the white, bolder when the person differentiates without color.
    private var opacity: Double {
        differentiateWithoutColor ? Self.boldOpacity : Self.opacity
    }

    /// The width of a line or a stripe, bolder when the person differentiates without color.
    private var lineWidth: CGFloat {
        differentiateWithoutColor ? Self.boldLineWidth : Self.lineWidth
    }

    /// The radius of a dot, bolder when the person differentiates without color.
    private var dotRadius: CGFloat {
        differentiateWithoutColor ? Self.boldDotRadius : Self.dotRadius
    }

    var body: some View {
        Canvas { context, size in
            draw(in: &context, size: size)
        }
        .accessibilityHidden(true)
    }

    /// Draws the pattern across a region.
    ///
    /// - Parameters:
    ///   - context: The context to draw in.
    ///   - size: The size of the region to fill.
    private func draw(in context: inout GraphicsContext, size: CGSize) {
        let ink = Color.white.opacity(opacity)
        switch pattern {
        case .blank:
            break
        case .diagonalLines:
            context.stroke(diagonalLines(in: size), with: .color(ink), lineWidth: lineWidth)
        case .dots:
            context.fill(dots(in: size), with: .color(ink))
        case .horizontalStripes:
            context.stroke(stripes(in: size), with: .color(ink), lineWidth: lineWidth)
        }
    }

    /// Returns slanted lines that cover a region.
    ///
    /// Each line runs one line width past every edge, so the square ends of
    /// the strokes fall outside the region and leave no notches.
    ///
    /// - Parameter size: The size of the region to cover.
    private func diagonalLines(in size: CGSize) -> Path {
        var path = Path()
        let overshoot = lineWidth
        let first = -size.height - overshoot
        let last = size.width + overshoot
        for start in stride(from: first, through: last, by: Self.gap) {
            path.move(to: CGPoint(x: start - overshoot, y: size.height + overshoot))
            path.addLine(to: CGPoint(x: start + size.height + overshoot, y: -overshoot))
        }
        return path
    }

    /// Returns level stripes that cover a region.
    ///
    /// - Parameter size: The size of the region to cover.
    private func stripes(in size: CGSize) -> Path {
        var path = Path()
        for height in stride(from: Self.gap / 2, through: size.height, by: Self.gap) {
            path.move(to: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: size.width, y: height))
        }
        return path
    }

    /// Returns a grid of dots that covers a region.
    ///
    /// - Parameter size: The size of the region to cover.
    private func dots(in size: CGSize) -> Path {
        var path = Path()
        for x in stride(from: Self.dotGap / 2, through: size.width, by: Self.dotGap) {
            for y in stride(from: Self.dotGap / 2, through: size.height, by: Self.dotGap) {
                path.addEllipse(
                    in: CGRect(
                        x: x - dotRadius,
                        y: y - dotRadius,
                        width: dotRadius * 2,
                        height: dotRadius * 2,
                    )
                )
            }
        }
        return path
    }
}
