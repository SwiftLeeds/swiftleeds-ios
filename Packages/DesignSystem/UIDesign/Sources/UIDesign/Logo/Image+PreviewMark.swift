#if DEBUG
import SwiftUI

extension Image {
    /// The side of the preview mark, in points.
    private static let previewMarkSide: CGFloat = 200

    /// The width of the preview mark's ring, in points.
    private static let previewMarkRingWidth: CGFloat = 28

    /// The share of the preview mark's side left clear on each edge of its centre dot.
    private static let previewMarkDotMarginShare: CGFloat = 0.35

    /// A made-up round mark of a ring and a dot, with no lettering, for previews.
    static var previewMark: Image {
        let size = CGSize(width: previewMarkSide, height: previewMarkSide)
        return Image(size: size) { context in
            let ring = CGRect(origin: .zero, size: size)
                .insetBy(dx: previewMarkRingWidth, dy: previewMarkRingWidth)
            context.stroke(Path(ellipseIn: ring), with: .color(.indigo), lineWidth: previewMarkRingWidth)
            let margin = size.width * previewMarkDotMarginShare
            let dot = CGRect(origin: .zero, size: size).insetBy(dx: margin, dy: margin)
            context.fill(Path(ellipseIn: dot), with: .color(.indigo))
        }
    }
}
#endif
