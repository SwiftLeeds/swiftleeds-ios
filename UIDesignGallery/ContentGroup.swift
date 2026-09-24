import SwiftUI
import UIDesign

/// A modifier that sets content on the surface a group of content sits on.
///
/// The surface is a material rather than a solid fill, so the ambient wash
/// behind it shows through. A hairline keeps the edge readable where the wash
/// and the material meet at nearly the same brightness.
struct ContentGroup: ViewModifier {
    /// The shape the surface and its hairline share.
    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: CGFloat(CornerRadius.large), style: .continuous)
    }

    func body(content: Content) -> some View {
        content
            .padding(.large)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial, in: shape)
            .overlay {
                shape.strokeBorder(.borderSecondary, lineWidth: CGFloat(BorderWidth.thin))
            }
    }
}

extension View {
    /// Sets this content on the surface a group of content sits on.
    func contentGroup() -> some View {
        modifier(ContentGroup())
    }
}
