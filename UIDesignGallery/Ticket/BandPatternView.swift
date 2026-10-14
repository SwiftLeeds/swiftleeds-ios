import SwiftUI

/// A view that draws a pattern in faint white, fading out toward its leading edge.
///
/// The pattern is decoration. It stays behind a label and fades out there, so
/// the label keeps its contrast.
struct BandPatternView: View {
    /// The pattern to draw.
    let pattern: BandPattern

    /// How strong the white is.
    private static let opacity: Double = 0.10

    /// How far across the view the fade ends, from 0 (leading) to 1 (trailing).
    private static let fadeEnd: Double = 0.85

    /// The distance between the lines or stripes.
    private static let gap: CGFloat = 12

    /// The width of a line or a stripe.
    private static let lineWidth: CGFloat = 3

    /// The radius of a dot.
    private static let dotRadius: CGFloat = 2.5

    /// The distance between the centers of two dots.
    private static let dotGap: CGFloat = 14

    var body: some View {
        Canvas { context, size in
            draw(in: &context, size: size)
        }
        .mask {
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: Self.fadeEnd),
                ],
                startPoint: .leading,
                endPoint: .trailing,
            )
        }
        .accessibilityHidden(true)
    }

    /// Draws the pattern across a region.
    ///
    /// - Parameters:
    ///   - context: The context to draw in.
    ///   - size: The size of the region to fill.
    private func draw(in context: inout GraphicsContext, size: CGSize) {
        let ink = Color.white.opacity(Self.opacity)
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
    /// - Parameter size: The size of the region to cover.
    private func diagonalLines(in size: CGSize) -> Path {
        var path = Path()
        for start in stride(from: -size.height, through: size.width, by: Self.gap) {
            path.move(to: CGPoint(x: start, y: size.height))
            path.addLine(to: CGPoint(x: start + size.height, y: 0))
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
