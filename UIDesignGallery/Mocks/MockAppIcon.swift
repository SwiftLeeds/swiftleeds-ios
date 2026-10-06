import SwiftUI
import UIDesign

/// A view that stands in for one of the app's Home Screen icons.
///
/// A real app icon is a fixed picture, so these colors do not follow the
/// appearance. A dark icon stays dark in both.
///
/// The swatch is the thing a person is choosing, so it is essential content
/// and grows with the text size.
struct MockAppIcon: View {
    /// The icon this swatch stands for.
    let icon: SampleAppIcon

    /// How wide and tall the swatch is.
    ///
    /// It starts at the smallest comfortable touch target, so a person can see
    /// the glyph at the default text size.
    @ScaledMetric(relativeTo: .body) private var side = CGFloat(IconSize.xxLarge)

    var body: some View {
        RoundedRectangle(cornerRadius: CGFloat(CornerRadius.medium), style: .continuous)
            .fill(fill)
            .overlay {
                Image(systemName: icon.symbol)
                    .font(.headline)
                    .foregroundStyle(glyph)
            }
            .overlay {
                RoundedRectangle(cornerRadius: CGFloat(CornerRadius.medium), style: .continuous)
                    .strokeBorder(.borderPrimary, lineWidth: CGFloat(BorderWidth.thin))
            }
            .frame(width: side, height: side)
            .accessibilityHidden(true)
    }

    /// The color behind the glyph.
    private var fill: Color {
        switch icon {
        case .classic: .brandPrimary
        case .night: .black
        case .kotlinLeeds: .white
        }
    }

    /// The color of the glyph itself.
    private var glyph: Color {
        switch icon {
        case .classic: .white
        case .night: .white
        case .kotlinLeeds: .black
        }
    }
}
