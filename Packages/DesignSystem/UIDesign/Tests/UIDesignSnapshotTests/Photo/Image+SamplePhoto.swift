#if os(iOS) || os(watchOS)
import SwiftUI

extension Image {
    /// The width of ``samplePhoto``, in points.
    static let samplePhotoWidth: CGFloat = 300

    /// The height of ``samplePhoto``, in points.
    static let samplePhotoHeight: CGFloat = 200

    /// The width of each colored bar at the left and right edges of ``samplePhoto``, in points.
    static let samplePhotoBarWidth: CGFloat = 30

    /// The color of the bar at the leading edge of ``samplePhoto``.
    static let samplePhotoLeadingBar = Color(
        .sRGB, red: 0.9, green: 0.1, blue: 0.1,  // swiftlint:disable:this no_magic_numbers - fixture data
    )

    /// The color of the bar at the trailing edge of ``samplePhoto``.
    static let samplePhotoTrailingBar = Color(
        .sRGB, red: 0.8, green: 0.1, blue: 0.8,  // swiftlint:disable:this no_magic_numbers - fixture data
    )

    /// The color of the sky in ``samplePhoto``, which is also its center color.
    static let samplePhotoSky = Color(
        .sRGB, red: 0.3, green: 0.55, blue: 0.85,  // swiftlint:disable:this no_magic_numbers - fixture data
    )

    /// The color of the ground band in ``samplePhoto``.
    static let samplePhotoGround = Color(
        .sRGB, red: 0.25, green: 0.6, blue: 0.3,  // swiftlint:disable:this no_magic_numbers - fixture data
    )

    /// The color of the sun in ``samplePhoto``.
    static let samplePhotoSun = Color(
        .sRGB, red: 0.95, green: 0.85, blue: 0.2,  // swiftlint:disable:this no_magic_numbers - fixture data
    )

    /// A made-up 3:2 scene drawn in code: a sky, a ground band and a sun left of center.
    ///
    /// A colored bar runs down each side, so a test can tell whether a crop spilled.
    static var samplePhoto: Image {
        let size = CGSize(width: samplePhotoWidth, height: samplePhotoHeight)
        return Image(size: size) { context in
            drawSamplePhoto(in: &context, size: size)
        }
    }

    /// Draws the scene of ``samplePhoto``.
    ///
    /// - Parameters:
    ///   - context: The context to draw into.
    ///   - size: The size of the picture.
    private static func drawSamplePhoto(in context: inout GraphicsContext, size: CGSize) {
        let horizon = size.height * 0.7  // swiftlint:disable:this no_magic_numbers - fixture data
        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(samplePhotoSky))
        context.fill(
            Path(CGRect(x: 0, y: horizon, width: size.width, height: size.height - horizon)),
            with: .color(samplePhotoGround),
        )
        context.fill(Path(ellipseIn: sunRect(in: size)), with: .color(samplePhotoSun))
        context.fill(
            Path(CGRect(x: 0, y: 0, width: samplePhotoBarWidth, height: size.height)),
            with: .color(samplePhotoLeadingBar),
        )
        context.fill(
            Path(CGRect(x: size.width - samplePhotoBarWidth, y: 0, width: samplePhotoBarWidth, height: size.height)),
            with: .color(samplePhotoTrailingBar),
        )
    }

    /// Returns the rectangle that holds the sun, left of center.
    ///
    /// - Parameter size: The size of the picture.
    /// - Returns: The sun's bounding rectangle.
    private static func sunRect(in size: CGSize) -> CGRect {
        let side = size.height * 0.25  // swiftlint:disable:this no_magic_numbers - fixture data
        let left = size.width * 0.3  // swiftlint:disable:this no_magic_numbers - fixture data
        let top = size.height * 0.15  // swiftlint:disable:this no_magic_numbers - fixture data
        return CGRect(x: left, y: top, width: side, height: side)
    }
}
#endif
