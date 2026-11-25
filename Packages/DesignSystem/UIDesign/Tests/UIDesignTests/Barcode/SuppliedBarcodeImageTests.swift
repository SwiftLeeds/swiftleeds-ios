#if canImport(CoreImage)
import CoreGraphics
import Testing
import UIDesign
import UIDesignTestSupport

#if os(macOS)
import Vision
#endif

struct SuppliedBarcodeImageTests {
    /// Which half of a picture holds the dark marks once the image is thresholded.
    enum BlackSide: Sendable {
        /// The left half is black and the right half is clear.
        case left

        /// The right half is black and the left half is clear.
        case right
    }

    /// A made-up picture to threshold, and what its halves should become.
    struct Fixture: Sendable, CustomTestStringConvertible {
        /// The name the test report shows.
        let testDescription: String

        /// The color of the left half.
        let mark: RGBAPixels.Pixel

        /// The color of the right half.
        let background: RGBAPixels.Pixel

        /// The most each color channel moves, from 0 to 255.
        let noise: Int

        /// The half that should come out black.
        let blackSide: BlackSide

        /// Every picture the threshold must split into black and clear.
        static let all = [
            Self(testDescription: "black on white", mark: .black, background: .white, noise: 0, blackSide: .left),
            Self(
                testDescription: "light blue on white",
                mark: .lightBlue,
                background: .white,
                noise: 0,
                blackSide: .left,
            ),
            Self(
                testDescription: "dark grey on light grey",
                mark: .darkGrey,
                background: .lightGrey,
                noise: 0,
                blackSide: .left,
            ),
            Self(testDescription: "black on clear", mark: .black, background: .clear, noise: 0, blackSide: .left),
            Self(testDescription: "white on black", mark: .white, background: .black, noise: 0, blackSide: .right),
            Self(
                testDescription: "black on white with noise",
                mark: .black,
                background: .white,
                noise: 6,
                blackSide: .left,
            ),
            Self(testDescription: "red on white", mark: .red, background: .white, noise: 0, blackSide: .left),
        ]
    }

    /// The text the light blue code carries, made up.
    private static let codeText = "ti_ExampleTicket0000000000"

    /// How many rows of position step the pattern that lowers each pixel of the almost white picture.
    private static let noiseRowStep = 3

    /// The most a pixel of the almost white picture is lowered from white, out of 255.
    private static let loweredLevels = 3

    /// The JPEG quality of the code a server might send, from 0 to 1.
    private static let jpegQuality = 0.7

    @Test(arguments: Fixture.all)
    func whenImageIsSupplied_shouldTurnDarkAreasBlackAndLightAreasClear(fixture: Fixture) throws {
        let source = try TwoToneImage.image(mark: fixture.mark, background: fixture.background, noise: fixture.noise)
        let sut = try SuppliedBarcodeImage(source)
        let pixels = try RGBAPixels(of: sut.cgImage)
        let leftIsBlack = fixture.blackSide == .left
        let leftMisses = pixels.count(columns: TwoToneImage.markColumns, rows: pixels.rows) { pixel in
            !(leftIsBlack ? pixel.isOpaqueBlack : pixel.isClear)
        }
        let rightMisses = pixels.count(columns: TwoToneImage.backgroundColumns, rows: pixels.rows) { pixel in
            !(leftIsBlack ? pixel.isClear : pixel.isOpaqueBlack)
        }
        #expect(leftMisses == 0, "\(leftMisses) pixels of the left half are not as expected")
        #expect(rightMisses == 0, "\(rightMisses) pixels of the right half are not as expected")
    }

    @Test
    func whenImageIsSupplied_shouldKeepItsSize() throws {
        let source = try TwoToneImage.image(mark: .black, background: .white)
        let sut = try SuppliedBarcodeImage(source)
        #expect(sut.cgImage.width == source.width)
        #expect(sut.cgImage.height == source.height)
    }

    @Test
    func whenImageIsAlmostWhite_shouldDrawNoMarks() throws {
        let almostWhite = (0..<TwoToneImage.side).flatMap { row -> [RGBAPixels.Pixel] in
            (0..<TwoToneImage.side).map { column in
                let channel = UInt8.max - UInt8((column + Self.noiseRowStep * row) % (Self.loweredLevels + 1))
                return RGBAPixels.Pixel(red: channel, green: channel, blue: channel, alpha: .max)
            }
        }
        let source = try RGBAPixels(width: TwoToneImage.side, height: TwoToneImage.side, pixels: almostWhite).image
        let sut = try SuppliedBarcodeImage(source)
        let pixels = try RGBAPixels(of: sut.cgImage)
        let marks = pixels.count(columns: pixels.columns, rows: pixels.rows) { !$0.isClear }
        #expect(marks == 0, "\(marks) pixels are not clear")
    }

    @Test
    func whenJPEGCodeIsSupplied_shouldDrawSameModulesAsOriginal() throws {
        let original = try RGBAPixels(of: QRCode(Self.codeText).cgImage)
        let source = try JPEGRoundTrip.image(QRCode(Self.codeText).cgImage, quality: Self.jpegQuality)
        let sut = try SuppliedBarcodeImage(source)
        let drawn = try RGBAPixels(of: sut.cgImage)
        let positions = original.columns.flatMap { column in
            original.rows.map { PixelPosition(column: column, row: $0) }
        }
        let specks = positions.count { position in
            !drawn.pixel(at: position).isClear && original.pixel(at: position).isClear
        }
        let holes = positions.count { position in
            !drawn.pixel(at: position).isOpaqueBlack && original.pixel(at: position).isOpaqueBlack
        }
        #expect(specks == 0, "\(specks) pixels are not clear where the code is clear")
        #expect(holes == 0, "\(holes) pixels are not black where the code is black")
    }

    #if os(macOS)
    @Test
    func whenLightBlueCodeIsSupplied_shouldScanBackAsCodeText() throws {
        let source = try LightBlueCodeImage.ticket
        let sut = try SuppliedBarcodeImage(source)
        let text = BarcodeReader.payload(of: sut.cgImage, as: .qr)
        #expect(text == Self.codeText)
    }
    #endif
}

/// The colors only the threshold fixtures use.
extension RGBAPixels.Pixel {
    /// A channel at 0.3 of 255.
    private static let threeTenths: UInt8 = 77

    /// A channel at 0.8 of 255.
    private static let eightTenths: UInt8 = 204

    /// Opaque red: red 255, green 0 and blue 0.
    fileprivate static let red = Self(red: .max, green: 0, blue: 0, alpha: .max)

    /// An opaque dark grey: 0.3 in every channel.
    fileprivate static let darkGrey = Self(red: threeTenths, green: threeTenths, blue: threeTenths, alpha: .max)

    /// An opaque light grey: 0.8 in every channel.
    fileprivate static let lightGrey = Self(red: eightTenths, green: eightTenths, blue: eightTenths, alpha: .max)
}
#endif
