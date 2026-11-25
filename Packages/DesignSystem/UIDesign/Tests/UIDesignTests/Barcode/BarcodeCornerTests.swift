#if os(macOS)
import SwiftUI
import Testing
import UIDesign
import UIDesignTestSupport

@MainActor
struct BarcodeCornerTests {
    /// One quarter of a rendered picture, named for the corner it holds.
    private enum Corner: CaseIterable, Sendable {
        /// The top left quarter.
        case topLeft

        /// The top right quarter.
        case topRight

        /// The bottom left quarter.
        case bottomLeft

        /// The bottom right quarter.
        case bottomRight

        /// The number of halves a picture is cut into along each side.
        private static let halves = 2

        /// The columns this quarter spans.
        ///
        /// - Parameter width: The width of the picture in pixels.
        /// - Returns: The columns, from the left.
        func columns(width: Int) -> Range<Int> {
            let middle = width / Self.halves
            return switch self {
            case .topLeft: 0..<middle
            case .bottomLeft: 0..<middle
            case .topRight: middle..<width
            case .bottomRight: middle..<width
            }
        }

        /// The rows this quarter spans.
        ///
        /// - Parameter height: The height of the picture in pixels.
        /// - Returns: The rows, from the top.
        func rows(height: Int) -> Range<Int> {
            let middle = height / Self.halves
            return switch self {
            case .topLeft: 0..<middle
            case .topRight: 0..<middle
            case .bottomLeft: middle..<height
            case .bottomRight: middle..<height
            }
        }
    }

    /// The scale of the pictures whose corners are compared.
    private static let cornerScale = RenderScale(pixelsPerPoint: 2)

    /// Renders a view to its pixels.
    ///
    /// - Parameter view: The view to render.
    /// - Returns: The pixels of the picture.
    /// - Throws: When the picture cannot be made or read.
    private func pixels(of view: some View) throws -> RGBAPixels {
        try RGBAPixels(of: CGImage.rendering(view, atScale: Self.cornerScale))
    }

    /// Counts the marks the plate removes from one quarter of the picture.
    ///
    /// - Parameters:
    ///   - corner: The quarter to count in.
    ///   - bare: The code drawn with no plate.
    ///   - plated: The code drawn with the default style.
    /// - Returns: The number of pixels that are a dark mark in `bare` and not in `plated`.
    private static func cutMarkCount(in corner: Corner, bare: RGBAPixels, plated: RGBAPixels) -> Int {
        corner.rows(height: plated.height).reduce(0) { total, row in
            total
                + corner.columns(width: plated.width).filter { column in
                    let position = PixelPosition(column: column, row: row)
                    return bare.pixel(at: position).isOpaqueBlack && !plated.pixel(at: position).isOpaqueBlack
                }.count
        }
    }

    @Test(arguments: BarcodeFixture.generated)
    func whenDrawnAtTypicalFrame_shouldKeepEveryMarkClearOfRoundedCorner(fixture: BarcodeFixture) throws {
        let code = try fixture.content
        let plated = try pixels(
            of: Barcode(code, label: Text("Code"))
                .frame(width: fixture.frameWidth, height: fixture.frameHeight)
        )
        let bare = try pixels(
            of: Image(code.cgImage, scale: 1, label: Text("Code"))
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(width: fixture.frameWidth, height: fixture.frameHeight)
        )
        try #require(plated.width == bare.width)
        try #require(plated.height == bare.height)
        for corner in Corner.allCases {
            let cut = Self.cutMarkCount(in: corner, bare: bare, plated: plated)
            #expect(cut == 0, "The plate cuts \(cut) mark pixels at the \(corner) corner")
        }
    }
}
#endif
