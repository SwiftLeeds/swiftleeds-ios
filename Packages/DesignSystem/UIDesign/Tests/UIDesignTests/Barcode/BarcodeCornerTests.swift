#if os(macOS)
import SwiftUI
import Testing
import UIDesign

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

    /// The pixels in one point of the render.
    private static let renderScale: CGFloat = 2

    /// The bytes that describe one pixel: red, green, blue and alpha.
    private static let bytesPerPixel = 4

    /// Renders a view to its pixels.
    ///
    /// - Parameter view: The view to render.
    /// - Returns: The pixels of the picture.
    /// - Throws: When the picture cannot be made or read.
    private func pixels(of view: some View) throws -> RenderedPixels {
        let renderer = ImageRenderer(content: view)
        renderer.scale = Self.renderScale
        return try RenderedPixels(of: try #require(renderer.cgImage))
    }

    /// Returns the height of a picture.
    ///
    /// - Parameter pixels: The picture.
    /// - Returns: The number of rows.
    private static func height(of pixels: RenderedPixels) -> Int {
        pixels.bytes.count / bytesPerPixel / pixels.side
    }

    /// Counts the marks the plate removes from one quarter of the picture.
    ///
    /// - Parameters:
    ///   - corner: The quarter to count in.
    ///   - bare: The code drawn with no plate.
    ///   - plated: The code drawn with the default style.
    /// - Returns: The number of pixels that are a dark mark in `bare` and not in `plated`.
    private static func cutMarkCount(in corner: Corner, bare: RenderedPixels, plated: RenderedPixels) -> Int {
        corner.rows(height: height(of: plated)).reduce(0) { total, row in
            total
                + corner.columns(width: plated.side).filter { column in
                    bare.isOpaqueBlack(column: column, row: row)
                        && !plated.isOpaqueBlack(column: column, row: row)
                }.count
        }
    }

    @Test(arguments: BarcodeFixture.allCases)
    func whenDrawnAtTypicalFrame_shouldKeepEveryMarkClearOfRoundedCorner(fixture: BarcodeFixture) throws {
        let code = try fixture.makeContent()
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
        try #require(plated.side == bare.side)
        try #require(Self.height(of: plated) == Self.height(of: bare))
        for corner in Corner.allCases {
            let cut = Self.cutMarkCount(in: corner, bare: bare, plated: plated)
            #expect(cut == 0, "The plate cuts \(cut) mark pixels at the \(corner) corner")
        }
    }
}
#endif
