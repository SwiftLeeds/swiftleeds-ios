#if canImport(CoreImage)
import CoreImage
import SwiftUI
import Testing
import UIDesign

@MainActor
struct QRCodeTests {
    /// The pixels of a rendered picture, read as 8-bit sRGB with alpha.
    ///
    /// A named copy of `Pixels` in the snapshot tests, which compiles on iOS and watchOS only.
    private struct RenderedPixels {
        /// The width and height of the picture in pixels.
        let side: Int

        /// The bytes of the picture, one row after another, as red, green, blue and alpha.
        let bytes: [UInt8]

        /// Creates the pixels of a picture by drawing it into an 8-bit sRGB context.
        ///
        /// - Parameter picture: The square picture to read.
        /// - Throws: When the context cannot be made.
        init(of picture: CGImage) throws {
            let space = try #require(CGColorSpace(name: CGColorSpace.sRGB))
            let context = try #require(
                CGContext(
                    data: nil,
                    width: picture.width,
                    height: picture.height,
                    bitsPerComponent: QRCodeTests.bitsPerChannel,
                    bytesPerRow: picture.width * QRCodeTests.bytesPerPixel,
                    space: space,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue,
                )
            )
            context.draw(picture, in: CGRect(x: 0, y: 0, width: picture.width, height: picture.height))
            let data = try #require(context.data)
            let count = picture.width * picture.height * QRCodeTests.bytesPerPixel
            side = picture.width
            bytes = Array(UnsafeBufferPointer(start: data.assumingMemoryBound(to: UInt8.self), count: count))
        }

        /// Returns one byte of a pixel.
        ///
        /// - Parameters:
        ///   - offset: The byte in the pixel: 0 red, 1 green, 2 blue, 3 alpha.
        ///   - column: The column of the pixel.
        ///   - row: The row of the pixel.
        /// - Returns: The byte, from 0 to 255.
        private func byte(_ offset: Int, column: Int, row: Int) -> Int {
            Int(bytes[(row * side + column) * QRCodeTests.bytesPerPixel + offset])
        }

        /// Returns whether a pixel is fully clear.
        ///
        /// - Parameters:
        ///   - column: The column of the pixel.
        ///   - row: The row of the pixel.
        /// - Returns: `true` when its alpha is within the tolerance of 0.
        func isClear(column: Int, row: Int) -> Bool {
            byte(QRCodeTests.alphaOffset, column: column, row: row) <= QRCodeTests.channelTolerance
        }

        /// Returns whether a pixel is opaque black.
        ///
        /// - Parameters:
        ///   - column: The column of the pixel.
        ///   - row: The row of the pixel.
        /// - Returns: `true` when each color channel is within the tolerance of 0 and alpha of 255.
        func isOpaqueBlack(column: Int, row: Int) -> Bool {
            let colors = (0..<QRCodeTests.alphaOffset).allSatisfy {
                byte($0, column: column, row: row) <= QRCodeTests.channelTolerance
            }
            let alpha = byte(QRCodeTests.alphaOffset, column: column, row: row)
            return colors && alpha >= QRCodeTests.largestChannel - QRCodeTests.channelTolerance
        }
    }

    /// The text the code carries.
    private static let fixtureText = "ti_ExampleTicket0000000000"

    /// The side of the square the code is drawn in, in points.
    private static let drawnSide: CGFloat = 220

    /// How many pixels the renderer draws for each point.
    private static let renderScale: CGFloat = 8

    /// The modules across the drawn code, with its quiet zone.
    ///
    /// The fixture is 33 modules, and the quiet zone adds 4 on each side.
    private static let modulesWithQuietZone = 41

    /// The modules of clear quiet zone on each side of the code.
    private static let quietZoneModules = 4

    /// How far a channel may sit from its expected value.
    ///
    /// A channel runs from 0 to 255.
    nonisolated private static let channelTolerance = 8

    /// The distance from the top and the leading edge to the first dark module's center.
    ///
    /// It is counted in modules.
    private static let firstModuleCenter = 4.5

    /// The largest value of one channel.
    nonisolated private static let largestChannel = 255

    /// The bytes that describe one pixel: red, green, blue and alpha.
    nonisolated private static let bytesPerPixel = 4

    /// The position of the alpha byte in a pixel, after red, green and blue.
    nonisolated private static let alphaOffset = 3

    /// The number of bits in one channel.
    nonisolated private static let bitsPerChannel = 8

    /// The most bytes of text a code holds.
    private static let capacityInBytes = 1_273

    /// The number of two-byte characters whose text is one byte over the capacity.
    private static let twoByteCharactersOverCapacity = 637

    /// Returns the picture of a code on its plate, as a scanner would see it.
    ///
    /// - Parameter code: The code to draw.
    /// - Returns: The rendered picture.
    /// - Throws: When the renderer draws no picture.
    private static func render(_ code: QRCode) throws -> CGImage {
        let content = Image(code, label: Text("Test code"))
            .resizable()
            .interpolation(.none)
            .frame(width: drawnSide, height: drawnSide)
            .background(.scannableSurface)
        let renderer = ImageRenderer(content: content)
        renderer.scale = renderScale
        return try #require(renderer.cgImage)
    }

    /// Returns the picture of a code with nothing behind it.
    ///
    /// - Parameter code: The code to draw.
    /// - Returns: The rendered picture, with alpha.
    /// - Throws: When the renderer draws no picture.
    private static func renderWithoutPlate(_ code: QRCode) throws -> CGImage {
        let content = Image(code, label: Text("Test code"))
            .resizable()
            .interpolation(.none)
            .frame(width: drawnSide, height: drawnSide)
        let renderer = ImageRenderer(content: content)
        renderer.scale = renderScale
        return try #require(renderer.cgImage)
    }

    /// Returns the text the first QR code in a picture carries.
    ///
    /// - Parameter picture: The picture to scan.
    /// - Returns: The message, or `nil` when no code is found.
    /// - Throws: When CoreImage makes no QR detector.
    private static func scan(_ picture: CGImage) throws -> String? {
        let detector = try #require(
            CIDetector(
                ofType: CIDetectorTypeQRCode,
                context: nil,
                options: [CIDetectorAccuracy: CIDetectorAccuracyHigh],
            )
        )
        let features = detector.features(in: CIImage(cgImage: picture))
        return features.compactMap { ($0 as? CIQRCodeFeature)?.messageString }.first
    }

    @Test
    func whenTextIsEncoded_shouldDrawBlackModulesInsideClearFourModuleQuietZone() throws {
        let code = try QRCode(Self.fixtureText)
        let pixels = try RenderedPixels(of: try Self.renderWithoutPlate(code))
        let modulePixels = Double(pixels.side) / Double(Self.modulesWithQuietZone)
        let ring = Double(Self.quietZoneModules) * modulePixels
        let inner = Double(Self.modulesWithQuietZone - Self.quietZoneModules) * modulePixels
        let indices = 0..<pixels.side
        let unclear = indices.flatMap { row in
            indices.filter { column in
                let isInRing = [column, row].contains { Double($0) + 0.5 < ring || Double($0) + 0.5 > inner }
                return isInRing && !pixels.isClear(column: column, row: row)
            }
        }
        let sample = Int(Self.firstModuleCenter * modulePixels)
        #expect(unclear.isEmpty, "\(unclear.count) pixels in the quiet zone are not clear")
        #expect(pixels.isOpaqueBlack(column: sample, row: sample))
    }

    @Test
    func whenTextIsEmpty_shouldThrowEmpty() {
        #expect(throws: QRCode.ParsingError.empty) { try QRCode("") }
    }

    @Test
    func whenTextIsAtCapacity_shouldEncode() throws {
        let text = String(repeating: "a", count: Self.capacityInBytes)
        let code = try QRCode(text)
        let message = try Self.scan(try Self.render(code))
        #expect(message == text)
    }

    @Test
    func whenTextIsOneByteOverCapacity_shouldThrowTooLong() {
        let text = String(repeating: "a", count: Self.capacityInBytes + 1)
        #expect(throws: QRCode.ParsingError.tooLong) { try QRCode(text) }
    }

    @Test
    func whenMultibyteTextIsOverCapacityInBytes_shouldThrowTooLong() {
        let text = String(repeating: "\u{E9}", count: Self.twoByteCharactersOverCapacity)
        #expect(throws: QRCode.ParsingError.tooLong) { try QRCode(text) }
    }

    @Test
    func whenTextIsEncoded_shouldScanBackAsSameText() throws {
        let code = try QRCode(Self.fixtureText)
        let message = try Self.scan(try Self.render(code))
        #expect(message == Self.fixtureText)
    }
}
#endif
