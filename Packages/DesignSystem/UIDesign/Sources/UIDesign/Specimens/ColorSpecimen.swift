#if DEBUG
import SwiftUI

/// A view that shows every color token, labeled by its name within its group.
package struct ColorSpecimen: View {
    /// A view that draws a color in a stroked swatch, visible on its own surface.
    private struct Swatch<Style: ShapeStyle>: View {
        /// The shape style the swatch shows.
        private let style: Style

        /// Creates a swatch that shows a shape style.
        ///
        /// - Parameter style: The shape style to show.
        init(_ style: Style) {
            self.style = style
        }

        /// A rounded rectangle filled with the style and outlined.
        var body: some View {
            RoundedRectangle(cornerRadius: CGFloat(CornerRadius.small))
                .fill(style)
                .frame(width: Sample.width, height: Sample.height)
                .overlay {
                    RoundedRectangle(cornerRadius: CGFloat(CornerRadius.small))
                        .strokeBorder(.opaqueBorder, lineWidth: CGFloat(BorderWidth.thin))
                }
        }
    }

    /// A swatch with the letters "Aa" drawn on it.
    private struct GlyphSwatch<Glyph: ShapeStyle, Fill: ShapeStyle>: View {
        /// The shape style of the letters.
        private let glyph: Glyph

        /// The shape style of the swatch.
        private let fill: Fill

        /// Creates a swatch of a shape style with letters on it.
        ///
        /// - Parameters:
        ///   - glyph: The shape style of the letters.
        ///   - fill: The shape style of the swatch.
        init(_ glyph: Glyph, on fill: Fill) {
            self.glyph = glyph
            self.fill = fill
        }

        /// The swatch with the letters over it.
        var body: some View {
            Swatch(fill)
                .overlay {
                    Text("Aa")
                        .foregroundStyle(glyph)
                }
        }
    }

    package init() {}

    package var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: .xLarge) { groups }
            VStack(alignment: .leading, spacing: .xLarge) { groups }
        }
        .padding(.large)
    }

    @ViewBuilder
    private var groups: some View {
        surfaceGroup
        textGroup
        borderGroup
        brandAndStatusGroup
        familiesGroup
    }
}

// MARK: - Groups

extension ColorSpecimen {
    fileprivate var surfaceGroup: some View {
        SpecimenGroup("Surface") {
            GridRow {
                Text("surface")
                Swatch(.surface)
            }
            GridRow {
                Text("secondary")
                Swatch(.secondarySurface)
            }
            GridRow {
                Text("tertiary")
                Swatch(.tertiarySurface)
            }
        }
    }

    fileprivate var textGroup: some View {
        SpecimenGroup("Text") {
            GridRow {
                Text("text")
                Swatch(.text)
            }
            GridRow {
                Text("secondary")
                Swatch(.secondaryText)
            }
            GridRow {
                Text("tertiary")
                Swatch(.tertiaryText)
            }
            GridRow {
                Text("disabled")
                Swatch(.disabledText)
            }
            GridRow {
                Text("onBrand")
                Swatch(.onBrand)
            }
        }
    }

    fileprivate var borderGroup: some View {
        SpecimenGroup("Border") {
            GridRow {
                Text("border")
                Swatch(.border)
            }
            GridRow {
                Text("opaque")
                Swatch(.opaqueBorder)
            }
        }
    }

    fileprivate var brandAndStatusGroup: some View {
        SpecimenGroup("Brand and status") {
            GridRow {
                Text("brand")
                Swatch(.brand)
            }
            GridRow {
                Text("success")
                Swatch(.success)
            }
            GridRow {
                Text("warning")
                Swatch(.warning)
            }
            GridRow {
                Text("error")
                Swatch(.error)
            }
            GridRow {
                Text("info")
                Swatch(.info)
            }
        }
    }
}

// MARK: - Families

extension ColorSpecimen {
    /// The table of color families, one row for each family.
    fileprivate var familiesGroup: some View {
        SpecimenGroup("Families") {
            familiesHeader
            ForEach(ColorFamily.allCases, id: \.self) { family in
                row(for: family)
            }
        }
    }

    /// The row of column names above the family samples.
    fileprivate var familiesHeader: some View {
        GridRow {
            Color.clear
                .gridCellUnsizedAxes([.horizontal, .vertical])
            Text("text")
            Text("solid")
            Text("subtle")
            Text("on grey")
        }
    }

    /// Returns a row with the family's name and its four samples.
    ///
    /// - Parameter family: The family to show.
    /// - Returns: The row.
    fileprivate func row(for family: ColorFamily) -> some View {
        GridRow {
            Text(String(describing: family))
            GlyphSwatch(family.text, on: .surface)
            GlyphSwatch(family.onSolid, on: family.solid)
            GlyphSwatch(family.text, on: family.subtle)
            Swatch(.secondarySurface)
                .overlay {
                    RoundedRectangle(cornerRadius: CGFloat(CornerRadius.small))
                        .fill(family.subtle)
                        .padding(.small)
                }
        }
    }
}

#Preview {
    ScrollView([.horizontal, .vertical]) {
        ColorSpecimen()
    }
}
#endif
