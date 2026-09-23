#if DEBUG
import SwiftUI

/// Draws every colour token beside its name.
///
/// Its snapshot pins each colour in both appearances, so a change shows up as a changed picture.
package struct ColorSpecimen: View {
    package init() {}

    package var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: Spacing.xLarge) { groups }
            VStack(alignment: .leading, spacing: Spacing.xLarge) { groups }
        }
        .padding(Spacing.large)
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

private extension ColorSpecimen {
    var surfaceGroup: some View {
        SpecimenGroup("Surface") {
            GridRow { Text("surface"); Swatch(.surface) }
            GridRow { Text("secondary"); Swatch(.secondarySurface) }
            GridRow { Text("tertiary"); Swatch(.tertiarySurface) }
        }
    }

    var textGroup: some View {
        SpecimenGroup("Text") {
            GridRow { Text("primary"); Swatch(.textPrimary) }
            GridRow { Text("secondary"); Swatch(.textSecondary) }
            GridRow { Text("tertiary"); Swatch(.textTertiary) }
            GridRow { Text("disabled"); Swatch(.textDisabled) }
            GridRow { Text("onBrand"); Swatch(.textOnBrand) }
        }
    }

    var borderGroup: some View {
        SpecimenGroup("Border") {
            GridRow { Text("primary"); Swatch(.borderPrimary) }
            GridRow { Text("secondary"); Swatch(.borderSecondary) }
        }
    }

    var brandAndStatusGroup: some View {
        SpecimenGroup("Brand and status") {
            GridRow { Text("brand"); Swatch(.brandPrimary) }
            GridRow { Text("success"); Swatch(.success) }
            GridRow { Text("warning"); Swatch(.warning) }
            GridRow { Text("error"); Swatch(.error) }
            GridRow { Text("info"); Swatch(.info) }
        }
    }
}

// MARK: - Parts

// A stroke, because a surface swatch drawn on that same surface is otherwise invisible.
private struct Swatch: View {
    private let color: Color

    init(_ color: Color) {
        self.color = color
    }

    var body: some View {
        RoundedRectangle(cornerRadius: CornerRadius.small)
            .fill(color)
            .frame(width: Sample.width, height: Sample.height)
            .overlay {
                RoundedRectangle(cornerRadius: CornerRadius.small)
                    .strokeBorder(.borderSecondary, lineWidth: BorderWidth.thin)
            }
    }
}

#Preview {
    ScrollView([.horizontal, .vertical]) {
        ColorSpecimen()
    }
}
#endif
