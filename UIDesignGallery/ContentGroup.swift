import SwiftUI
import UIDesign

/// A modifier that sets content on the surface a group of content sits on.
///
/// The surface is a material rather than a solid fill, so the ambient wash
/// behind it shows through. A hairline keeps the edge readable where the wash
/// and the material meet at nearly the same brightness.
///
/// The surface adds no padding of its own. Content that is one block pads
/// itself; content that is a run of rows lets each row pad itself, so the gap
/// above a row and the gap below it stay equal across a separator.
struct ContentGroup: ViewModifier {
    /// The shape the surface and its hairline share.
    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: CGFloat(CornerRadius.large), style: .continuous)
    }

    /// How far the surface lifts off the wash behind it.
    ///
    /// A material alone over a dark screen stays dark. The lift is what makes
    /// the surface read as smoke over the wash rather than as a darker hole.
    private static let lift: Double = 0.07

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                shape
                    .fill(.ultraThinMaterial)
                    .overlay { shape.fill(.textPrimary.opacity(Self.lift)) }
            }
            .overlay {
                shape.strokeBorder(.borderSecondary, lineWidth: CGFloat(BorderWidth.thin))
            }
            .clipShape(shape)
    }
}

extension View {
    /// Sets this content on the surface a group of content sits on.
    func contentGroup() -> some View {
        modifier(ContentGroup())
    }
}
