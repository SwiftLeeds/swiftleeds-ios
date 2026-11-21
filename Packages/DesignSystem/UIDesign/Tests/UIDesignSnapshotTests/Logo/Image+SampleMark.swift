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

    /// The color of the wide sample mark's trailing bar.
    static let wideSampleMarkTrailingBar = Color(.sRGB, red: 0, green: 0, blue: 1)

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
}
#endif
