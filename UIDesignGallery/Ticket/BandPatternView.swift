import SwiftUI

/// A view that draws a pattern in faint white across its whole area.
///
/// The pattern is decoration. The label on top keeps its own contrast.
/// When the person turns on Differentiate Without Color, the pattern gets
/// stronger, so the roles tell apart in greyscale at a glance.
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

    /// The radius of a dot.
    private static let dotRadius: CGFloat = 2

    /// The distance between the centers of two dots.
    private static let dotGap: CGFloat = 10

    /// The strength of the white, stronger when the person differentiates
    /// without color.
    ///
    /// Only the strength changes. The lines and dots keep their size, so the
    /// halo around the label still clears them.
    private var opacity: Double {
        differentiateWithoutColor ? Self.boldOpacity : Self.opacity
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
            context.stroke(diagonalLines(in: size), with: .color(ink), lineWidth: Self.lineWidth)
        case .dots:
            context.fill(dots(in: size), with: .color(ink))
        case .horizontalStripes:
            context.stroke(stripes(in: size), with: .color(ink), lineWidth: Self.lineWidth)
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
        let overshoot = Self.lineWidth
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
                        x: x - Self.dotRadius,
                        y: y - Self.dotRadius,
                        width: Self.dotRadius * 2,
                        height: Self.dotRadius * 2,
                    )
                )
            }
        }
        return path
    }
}
