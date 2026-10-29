#if DEBUG
import Foundation
import SFSafeSymbols
import SwiftUI

/// A view that shows every opacity level, and the pattern opacity on a filled band.
package struct OpacitySpecimen: View {
    /// One level, drawn as a square of the primary color over an eye, with its percent.
    private struct Swatch: View {
        /// The symbol behind the square, which shows more as the level falls.
        private static let revealedIcon = Icon(.eyeFill)

        /// The level the square shows.
        private let level: OpacityLevel

        /// Creates a swatch of a level.
        ///
        /// - Parameter level: The level to draw the square at.
        init(_ level: OpacityLevel) {
            self.level = level
        }

        /// The square at the level over an eye, outlined, above its percent.
        var body: some View {
            VStack(spacing: .xxs) {
                Rectangle()
                    .fill(.primary)
                    .opacity(Double(level))
                    .frame(width: OpacitySpecimen.swatchSize, height: OpacitySpecimen.swatchSize)
                    .background { revealedSymbol }
                    .background(.surface)
                    .overlay {
                        Rectangle()
                            .strokeBorder(.opaqueBorder, lineWidth: .edge)
                    }
                Text(Double(level), format: .percent)
            }
        }

        /// The eye behind the square, in a color that differs from the square's.
        private var revealedSymbol: some View {
            Image(icon: Self.revealedIcon)
                .resizable()
                .scaledToFit()
                .padding(.sm)
                .foregroundStyle(ColorFamily.blue.solid)
                .accessibilityHidden(true)
        }
    }

    /// A band filled with a solid color, crossed by diagonal lines.
    private struct Band: View {
        /// The shading the lines are drawn with.
        private let shading: GraphicsContext.Shading

        /// Creates a band with lines drawn in a shading.
        ///
        /// - Parameter shading: The shading to draw the lines with.
        init(shading: GraphicsContext.Shading) {
            self.shading = shading
        }

        /// The filled band, with diagonal lines that run past every edge.
        var body: some View {
            Canvas { context, size in
                let level = LineWidth.pattern.level(for: context.environment.accessibilitySettings)
                context.stroke(
                    Self.lines(in: size, overshoot: CGFloat(level)),
                    with: shading,
                    lineWidth: .pattern,
                )
            }
            .frame(width: OpacitySpecimen.bandWidth, height: OpacitySpecimen.bandHeight)
            .background(ColorFamily.blue.solid)
        }

        /// Returns diagonal lines that cover a rectangle.
        ///
        /// Each line runs `overshoot` past every edge, so its square ends leave no notches.
        ///
        /// - Parameters:
        ///   - size: The size of the rectangle to cover.
        ///   - overshoot: The distance each line runs past an edge, such as one line width.
        /// - Returns: A path of lines that rise from left to right.
        private static func lines(in size: CGSize, overshoot: CGFloat) -> Path {
            var path = Path()
            for start in stride(
                from: -size.height - overshoot,
                through: size.width + overshoot,
                by: CGFloat(Spacing.md),
            ) {
                path.move(to: CGPoint(x: start - overshoot, y: size.height + overshoot))
                path.addLine(to: CGPoint(x: start + size.height + overshoot, y: -overshoot))
            }
            return path
        }
    }

    /// The appearance the page gray is chosen for.
    @Environment(\.colorScheme)
    private var colorScheme

    /// Creates a specimen of the opacity levels and the pattern opacity.
    package init() {}

    /// The two groups, one above the other, on a gray page.
    package var body: some View {
        VStack(alignment: .leading, spacing: .xl) {
            scaleGroup
            patternGroup
        }
        .padding(.lg)
        .background(Color(Hue.neutral.tone(pageTone)))
    }

    /// The gray of the page, apart from both a clear and an opaque swatch, with labels at 4.5:1.
    private var pageTone: Hue.Tone {
        switch colorScheme {
        case .dark: .t50

        default: .t65
        }
    }
}

// MARK: - Groups

extension OpacitySpecimen {
    /// The width and height of one swatch.
    fileprivate static let swatchSize: CGFloat = 40

    /// The number of swatches in one row of the scale.
    fileprivate static let swatchesPerRow = 6

    /// The width of the band.
    fileprivate static let bandWidth: CGFloat = 200

    /// The height of the band.
    fileprivate static let bandHeight: CGFloat = 48

    /// The scale, as rows of swatches from clear to opaque.
    fileprivate var scaleGroup: some View {
        SpecimenGroup("Scale") {
            ForEach(rowStarts, id: \.self) { start in
                GridRow {
                    ForEach(levels(startingAt: start), id: \.self) { level in
                        Swatch(level)
                    }
                }
            }
        }
    }

    /// The pattern opacity, with and without Differentiate Without Color.
    fileprivate var patternGroup: some View {
        SpecimenGroup("Pattern") {
            VStack(alignment: .leading, spacing: .xs) {
                Text("pattern")
                Band(shading: .style(ColorFamily.blue.onSolid.opacity(.pattern)))
            }
            VStack(alignment: .leading, spacing: .xs) {
                Text("pattern, Differentiate Without Color")
                Band(shading: .style(ColorFamily.blue.onSolid.opacity(Double(OpacityLevel.percent20))))
            }
        }
    }
}

// MARK: - Parts

extension OpacitySpecimen {
    /// The index in the scale where each row starts.
    fileprivate var rowStarts: [Int] {
        Array(stride(from: 0, to: OpacityLevel.allCases.count, by: Self.swatchesPerRow))
    }

    /// Returns the levels in the row that starts at an index.
    ///
    /// - Parameter start: The index of the first level in the row.
    /// - Returns: The levels in the row, ascending.
    fileprivate func levels(startingAt start: Int) -> [OpacityLevel] {
        let end = min(start + Self.swatchesPerRow, OpacityLevel.allCases.count)
        return Array(OpacityLevel.allCases[start..<end])
    }
}

#Preview {
    ScrollView([.horizontal, .vertical]) {
        OpacitySpecimen()
    }
}
#endif
