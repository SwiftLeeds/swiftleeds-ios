#if DEBUG
import SwiftUI

/// A view that shows every hue's tonal ramp, labeled by hue and tone.
package struct HueSpecimen: View {
    package init() {}

    package var body: some View {
        Grid(
            alignment: .center,
            horizontalSpacing: CGFloat(Spacing.xSmall),
            verticalSpacing: CGFloat(Spacing.xSmall),
        ) {
            toneHeader
            ForEach(Hue.allCases, id: \.self) { hue in
                row(for: hue)
            }
        }
        .font(.caption2)
        .padding(.large)
    }
}

// MARK: - Rows

extension HueSpecimen {
    /// The row of tone numbers above the swatches.
    fileprivate var toneHeader: some View {
        GridRow {
            Color.clear
                .gridCellUnsizedAxes([.horizontal, .vertical])
            ForEach(Hue.Tone.allCases, id: \.self) { tone in
                Text(tone.label)
                    .frame(width: Self.swatchSize)
            }
        }
    }

    /// Returns a row with the hue's name and one swatch for each tone.
    ///
    /// - Parameter hue: The hue to show.
    /// - Returns: The row.
    fileprivate func row(for hue: Hue) -> some View {
        GridRow {
            Text(String(describing: hue))
                .gridColumnAlignment(.leading)
            ForEach(Hue.Tone.allCases, id: \.self) { tone in
                Swatch(Color(hue.tone(tone)))
            }
        }
    }

    /// The width and height of one swatch.
    fileprivate static let swatchSize: CGFloat = 24
}

// MARK: - Parts

extension Hue.Tone {
    /// The tone's number, such as "50".
    fileprivate var label: String {
        String(describing: self).dropFirst().description
    }
}

/// One tone of a hue, drawn as a stroked square.
private struct Swatch: View {
    /// The color the square is filled with.
    private let color: Color

    /// Creates a swatch of a color.
    ///
    /// - Parameter color: The color to fill the square with.
    init(_ color: Color) {
        self.color = color
    }

    var body: some View {
        RoundedRectangle(cornerRadius: CGFloat(CornerRadius.small))
            .fill(color)
            .frame(width: HueSpecimen.swatchSize, height: HueSpecimen.swatchSize)
            // Without the stroke, a swatch close to the page color is invisible.
            .overlay {
                RoundedRectangle(cornerRadius: CGFloat(CornerRadius.small))
                    .strokeBorder(.opaqueBorder, lineWidth: CGFloat(BorderWidth.thin))
            }
    }
}

#Preview {
    ScrollView([.horizontal, .vertical]) {
        HueSpecimen()
    }
}
#endif
