#if canImport(CoreGraphics)
import CoreGraphics

/// The clear border of a stored barcode picture, read side by side.
///
/// ```swift
/// let sut = try QuietZoneProbe(of: code.cgImage, modulesAcross: 29, quietZoneModules: 2)
/// let isLeftClear = sut.isClear(on: .left)
/// ```
package struct QuietZoneProbe {
    /// One side of the picture.
    package enum Side: CaseIterable, Equatable, Hashable, Sendable {
        /// The left side.
        case left

        /// The right side.
        case right

        /// The top side.
        case top

        /// The bottom side.
        case bottom
    }

    /// The pixels of the picture.
    private let pixels: RGBAPixels

    /// The modules across the picture, quiet zone included.
    private let modulesAcross: Int

    /// The pixels each module spans, rounded down.
    private let moduleSpan: Int

    /// The width of the quiet zone in pixels.
    private let zone: Int

    /// Whether the picture gives every module a whole number of pixels.
    package var hasWholeModules: Bool {
        pixels.width == modulesAcross * moduleSpan
    }

    /// Creates a probe of a picture.
    ///
    /// - Parameters:
    ///   - image: The stored picture of the code.
    ///   - modulesAcross: The modules across the picture, quiet zone included.
    ///   - quietZoneModules: The modules of quiet zone the code keeps on each side.
    /// - Throws: ``RGBAPixels/ReadingError`` when the picture cannot be read.
    /// - Complexity: O(*n*), where *n* is the number of pixels in the picture.
    package init(of image: CGImage, modulesAcross: Int, quietZoneModules: Int) throws(RGBAPixels.ReadingError) {
        let pixels = try RGBAPixels(of: image)
        self.pixels = pixels
        self.modulesAcross = modulesAcross
        moduleSpan = pixels.width / modulesAcross
        zone = quietZoneModules * moduleSpan
    }

    /// Returns whether every pixel in the quiet zone on a side is clear.
    ///
    /// - Parameter side: The side to check.
    /// - Returns: Whether each pixel in the band along `side` is clear.
    /// - Complexity: O(*n*), where *n* is the number of pixels in the band.
    package func isClear(on side: Side) -> Bool {
        let area = strip(along: side, from: 0, thickness: zone)
        return pixels.isClear(columns: area.columns, rows: area.rows)
    }

    /// Returns whether a mark touches the inner edge of the quiet zone on a side.
    ///
    /// - Parameter side: The side to check.
    /// - Returns: Whether the module just inside the zone on `side` holds an opaque black pixel.
    /// - Complexity: O(*n*), where *n* is the number of pixels in the module's band.
    package func hasMark(justInside side: Side) -> Bool {
        let area = strip(along: side, from: zone, thickness: moduleSpan)
        return pixels.hasOpaqueBlack(columns: area.columns, rows: area.rows)
    }

    /// Returns the columns and rows of a strip of the picture that runs along one side.
    ///
    /// - Parameters:
    ///   - side: The side the strip runs along.
    ///   - offset: The pixels between the picture's edge and the strip.
    ///   - thickness: The pixels across the strip.
    /// - Returns: The columns and rows of the strip.
    private func strip(
        along side: Side,
        from offset: Int,
        thickness: Int,
    ) -> (columns: Range<Int>, rows: Range<Int>) {
        switch side {
        case .left: (offset..<(offset + thickness), pixels.rows)
        case .right: ((pixels.width - offset - thickness)..<(pixels.width - offset), pixels.rows)
        case .top: (pixels.columns, offset..<(offset + thickness))
        case .bottom: (pixels.columns, (pixels.height - offset - thickness)..<(pixels.height - offset))
        }
    }
}
#endif
