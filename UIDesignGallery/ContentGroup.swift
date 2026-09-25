import SwiftUI
import UIDesign

/// A view that fills the surface a group of content sits on.
///
/// The surface is a material rather than a solid fill, so the ambient wash
/// behind it shows through. It fills whatever it is given and rounds nothing,
/// so a caller that wants a card clips it and a `List` row leaves it square.
struct ContentSurface: View {
    /// How far the surface lifts off the wash behind it.
    ///
    /// A material alone over a dark screen stays dark. The lift is what makes
    /// the surface read as smoke over the wash rather than as a darker hole.
    private static let lift: Double = 0.07

    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .overlay { Color.textPrimary.opacity(Self.lift) }
    }
}

/// A modifier that sets content on the surface a group of content sits on.
///
/// A hairline keeps the edge readable where the wash and the material meet at
/// nearly the same brightness.
///
/// The surface adds no padding of its own. Content that is one block pads
/// itself; content that is a run of rows lets each row pad itself, so the gap
/// above a row and the gap below it stay equal across a separator.
struct ContentGroup: ViewModifier {
    /// The shape the surface and its hairline share.
    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: CGFloat(CornerRadius.large), style: .continuous)
    }

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .background { ContentSurface() }
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
