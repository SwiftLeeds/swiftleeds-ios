#if DEBUG
import SwiftUI

extension Image {
    /// The width of ``previewPhoto``, in points.
    private static let previewPhotoWidth: CGFloat = 300

    /// The height of ``previewPhoto``, in points.
    private static let previewPhotoHeight: CGFloat = 200

    /// Where the ground starts, as a fraction of the height.
    private static let previewHorizon: CGFloat = 0.7

    /// The sun's left edge, as a fraction of the width.
    private static let previewSunLeft: CGFloat = 0.3

    /// The sun's top edge, as a fraction of the height.
    private static let previewSunTop: CGFloat = 0.15

    /// The sun's side, as a fraction of the height.
    private static let previewSunSide: CGFloat = 0.25

    /// A made-up 3:2 scene drawn in code, for previews: a sky, a ground band and a sun.
    static var previewPhoto: Image {
        let size = CGSize(width: previewPhotoWidth, height: previewPhotoHeight)
        return Image(size: size) { context in
            drawPreviewPhoto(in: &context, size: size)
        }
    }

    /// Draws the scene of ``previewPhoto``.
    ///
    /// - Parameters:
    ///   - context: The context to draw into.
    ///   - size: The size of the picture.
    private static func drawPreviewPhoto(in context: inout GraphicsContext, size: CGSize) {
        let horizon = size.height * previewHorizon
        let ground = CGRect(x: 0, y: horizon, width: size.width, height: size.height - horizon)
        let side = size.height * previewSunSide
        let sun = CGRect(
            x: size.width * previewSunLeft,
            y: size.height * previewSunTop,
            width: side,
            height: side,
        )
        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.blue))
        context.fill(Path(ground), with: .color(.green))
        context.fill(Path(ellipseIn: sun), with: .color(.yellow))
    }
}
#endif
