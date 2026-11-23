#if os(iOS) || os(watchOS)
import SwiftUI

extension Image {
    /// The width of the wide sample mark, in points.
    static let wideSampleMarkWidth: CGFloat = 400

    /// The height of the wide sample mark, in points.
    static let wideSampleMarkHeight: CGFloat = 100

    /// The number of equal bars in the wide sample mark.
    private static let wideSampleMarkBarCount: CGFloat = 2

    /// The color of the wide sample mark's leading bar.
    static let wideSampleMarkLeadingBar = Color(.sRGB, red: 1, green: 0, blue: 0)

    /// The color of the wide sample mark's trailing bar, a navy.
    static let wideSampleMarkTrailingBar = Color(
        .sRGB,
        red: 0.05,  // swiftlint:disable:this no_magic_numbers - fixture data
        green: 0.1,  // swiftlint:disable:this no_magic_numbers - fixture data
        blue: 0.35,  // swiftlint:disable:this no_magic_numbers - fixture data
    )

    /// The side of the round sample marks, in points.
    private static let roundSampleMarkSide: CGFloat = 200

    /// The width of the dark sample mark's ring, in points.
    private static let darkInkSampleMarkRingWidth: CGFloat = 24

    /// The share of the dark sample mark's side left clear on each edge of its center dot.
    private static let darkInkSampleMarkDotMarginShare: CGFloat = 0.35

    /// The ink of the dark sample mark, a near black.
    private static let darkInk = Color(white: 0.1)  // swiftlint:disable:this no_magic_numbers - fixture data

    /// The space between the white-backed sample mark's edge and its circle, in points.
    private static let whiteBackedSampleMarkMargin: CGFloat = 60

    /// The color of the white-backed sample mark's circle.
    private static let whiteBackedSampleMarkCircle = Color(
        .sRGB,
        red: 0,
        green: 0.5,  // swiftlint:disable:this no_magic_numbers - fixture data
        blue: 0.55,  // swiftlint:disable:this no_magic_numbers - fixture data
    )

    /// A made-up wide mark of two solid bars that meet in the middle, with no lettering.
    ///
    /// The mark is four times as wide as it is tall, as a wordmark is.
    static var wideSampleMark: Image {
        let size = CGSize(width: wideSampleMarkWidth, height: wideSampleMarkHeight)
        return Image(size: size) { context in
            let half = size.width / wideSampleMarkBarCount
            context.fill(
                Path(CGRect(x: 0, y: 0, width: half, height: size.height)),
                with: .color(wideSampleMarkLeadingBar),
            )
            context.fill(
                Path(CGRect(x: half, y: 0, width: half, height: size.height)),
                with: .color(wideSampleMarkTrailingBar),
            )
        }
    }

    /// A made-up round mark of a ring and a dot in dark ink on a transparent background, with no lettering.
    static var darkInkSampleMark: Image {
        let size = CGSize(width: roundSampleMarkSide, height: roundSampleMarkSide)
        return Image(size: size) { context in
            let ring = CGRect(origin: .zero, size: size)
                .insetBy(dx: darkInkSampleMarkRingWidth, dy: darkInkSampleMarkRingWidth)
            context.stroke(Path(ellipseIn: ring), with: .color(darkInk), lineWidth: darkInkSampleMarkRingWidth)
            let margin = size.width * darkInkSampleMarkDotMarginShare
            let dot = CGRect(origin: .zero, size: size).insetBy(dx: margin, dy: margin)
            context.fill(Path(ellipseIn: dot), with: .color(darkInk))
        }
    }

    /// A made-up mark of a colored circle on an opaque white square that fills the whole image.
    static var whiteBackedSampleMark: Image {
        let size = CGSize(width: roundSampleMarkSide, height: roundSampleMarkSide)
        return Image(size: size) { context in
            let field = CGRect(origin: .zero, size: size)
            context.fill(Path(field), with: .color(.white))
            let circle = field.insetBy(dx: whiteBackedSampleMarkMargin, dy: whiteBackedSampleMarkMargin)
            context.fill(Path(ellipseIn: circle), with: .color(whiteBackedSampleMarkCircle))
        }
    }
}
#endif
