#if DEBUG
import SwiftUI

/// A view that shows every color token, labeled by its name within its group.
package struct ColorSpecimen: View {
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

// MARK: - Parts

// Stroked, or a surface swatch on that same surface is invisible.
private struct Swatch: View {
    private let color: Color

    init(_ color: Color) {
        self.color = color
    }

    var body: some View {
        RoundedRectangle(cornerRadius: CGFloat(CornerRadius.small))
            .fill(color)
            .frame(width: Sample.width, height: Sample.height)
            .overlay {
                RoundedRectangle(cornerRadius: CGFloat(CornerRadius.small))
                    .strokeBorder(.opaqueBorder, lineWidth: CGFloat(BorderWidth.thin))
            }
    }
}

#Preview {
    ScrollView([.horizontal, .vertical]) {
        ColorSpecimen()
    }
}
#endif
