#if DEBUG
import SwiftUI

/// A view that shows every brand's color roles and surfaces, one column for each brand.
package struct BrandSpecimen: View {
    /// A view that draws a label over a filled shape, outlined so it shows on its own surface.
    private struct Chip<Outline: InsettableShape>: View {
        /// The text the chip shows.
        private let label: String

        /// The color of the text.
        private let foreground: Color

        /// The color of the shape.
        private let fill: Color

        /// The outline of the chip.
        private let shape: Outline

        /// Creates a chip that shows a label.
        ///
        /// - Parameters:
        ///   - label: The text to show.
        ///   - foreground: The color of the text.
        ///   - fill: The color of the shape behind the text.
        ///   - shape: The outline of the chip.
        init(_ label: String, foreground: Color, on fill: Color, in shape: Outline) {
            self.label = label
            self.foreground = foreground
            self.fill = fill
            self.shape = shape
        }

        /// The label over the shape.
        var body: some View {
            Text(label)
                .foregroundStyle(foreground)
                .padding(.sm)
                .background(fill, in: shape)
                .overlay {
                    shape.strokeBorder(.opaqueBorder, lineWidth: .edge)
                }
        }
    }

    /// A view that draws a color in a stroked swatch, visible on its own surface.
    private struct Swatch: View {
        /// The color the swatch shows.
        private let color: Color

        /// Creates a swatch that shows a color.
        ///
        /// - Parameter color: The color to show.
        init(_ color: Color) {
            self.color = color
        }

        /// A rounded rectangle filled with the color and outlined.
        var body: some View {
            RoundedRectangle(cornerRadius: .tile)
                .fill(color)
                .frame(width: Sample.width, height: Sample.height)
                .overlay {
                    RoundedRectangle(cornerRadius: .tile)
                        .strokeBorder(.opaqueBorder, lineWidth: .edge)
                }
        }
    }

    /// The text that stands for text in a sample.
    private static let sampleText = "Schedule"

    /// The label that stands for a button in a sample.
    private static let buttonLabel = "Get Tickets"

    /// The outline of a sample that is not a button.
    private static let corners = RoundedRectangle(cornerRadius: .tile)

    /// Creates a specimen of every brand.
    package init() {}

    /// The brands side by side, or one above the other when they do not fit.
    package var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: .xl) { columns }
            VStack(alignment: .leading, spacing: .xl) { columns }
        }
        .padding(.lg)
    }

    /// One column for each brand.
    @ViewBuilder
    private var columns: some View {
        ForEach(Brand.allCases, id: \.self) { brand in
            column(for: brand)
        }
    }

    /// Returns a titled table of a brand's roles and surfaces.
    ///
    /// - Parameter brand: The brand to show.
    /// - Returns: The table.
    private func column(for brand: Brand) -> some View {
        SpecimenGroup(String(describing: brand)) {
            GridRow {
                Text("text")
                Chip(Self.sampleText, foreground: brand.text, on: brand.surface, in: Self.corners)
            }
            GridRow {
                Text("onSolid")
                Chip(Self.buttonLabel, foreground: brand.onSolid, on: brand.solid, in: Capsule())
            }
            GridRow {
                Text("subtle")
                Chip(Self.sampleText, foreground: brand.text, on: brand.subtle, in: Self.corners)
            }
            GridRow {
                Text("surface")
                Swatch(brand.surface)
            }
            GridRow {
                Text("secondary")
                Swatch(brand.secondarySurface)
            }
            GridRow {
                Text("tertiary")
                Swatch(brand.tertiarySurface)
            }
            GridRow {
                Text("grouped")
                Swatch(brand.groupedSurface)
            }
            GridRow {
                Text("secondary grouped")
                Swatch(brand.secondaryGroupedSurface)
            }
            GridRow {
                Text("tertiary grouped")
                Swatch(brand.tertiaryGroupedSurface)
            }
        }
    }
}

#Preview {
    ScrollView([.horizontal, .vertical]) {
        BrandSpecimen()
    }
}
#endif
