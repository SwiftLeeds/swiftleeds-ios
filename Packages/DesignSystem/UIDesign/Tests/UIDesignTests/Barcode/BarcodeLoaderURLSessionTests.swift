#if canImport(CoreImage)
import CoreGraphics
import Foundation
import ImageIO
import Testing
import UIDesign

// Everything that touches URLProtocolStub's shared state lives here:
// .serialized only serializes within one suite.
@Suite(.serialized)
struct BarcodeLoaderURLSessionTests {
    /// The reason the made-up picture could not be saved as PNG bytes.
    private enum EncodingError: Error {
        /// ImageIO made no PNG bytes.
        case notEncoded
    }

    /// The type identifier of a PNG file.
    private static let pngType = "public.png"

    /// The address every request goes to, made up.
    private let url: URL

    /// The bytes of a PNG with black on its left half and white on its right half.
    private let png: Data

    /// Creates the made-up address and picture, and forgets any earlier stub answer.
    init() throws {
        URLProtocolStub.removeAnswer()
        url = try #require(URL(string: "https://barcode.example.com/code.png"))
        png = try Self.pngData(of: TwoToneImage.image(mark: .black, background: .white))
    }

    /// Returns the bytes of a picture saved as PNG.
    ///
    /// - Parameter picture: The picture to save.
    /// - Returns: The PNG file's bytes.
    /// - Throws: ``EncodingError/notEncoded`` when ImageIO makes no bytes.
    private static func pngData(of picture: CGImage) throws -> Data {
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(data, pngType as CFString, 1, nil) else {
            throw EncodingError.notEncoded
        }
        CGImageDestinationAddImage(destination, picture, nil)
        guard CGImageDestinationFinalize(destination) else { throw EncodingError.notEncoded }
        return data as Data
    }

    /// Returns the number of pixels in one half of a picture that are not as expected.
    ///
    /// - Parameters:
    ///   - pixels: The picture's pixels.
    ///   - leftHalf: Whether to check the left half or the right half.
    ///   - isBlack: Whether the half should be opaque black, or clear.
    /// - Returns: The number of pixels that are not as expected.
    private static func missCount(in pixels: RenderedPixels, leftHalf: Bool, isBlack: Bool) -> Int {
        let columns = leftHalf ? 0..<pixels.side / 2 : pixels.side / 2..<pixels.side
        return columns.flatMap { column in
            (0..<pixels.side).map { (column, $0) }
        }.count { column, row in
            let matches =
                isBlack
                ? pixels.isOpaqueBlack(column: column, row: row)
                : pixels.isClear(column: column, row: row)
            return !matches
        }
    }

    @Test
    func whenServerSendsPNG_shouldReturnMarksOnClear() async throws {
        URLProtocolStub.answer = .response(statusCode: 200, data: png)
        let sut = BarcodeLoader.urlSession(URLProtocolStub.session())

        let image = try await sut.load(URLRequest(url: url))

        let pixels = try RenderedPixels(of: image.cgImage)
        #expect(image.cgImage.width == TwoToneImage.side)
        #expect(image.cgImage.height == TwoToneImage.side)
        #expect(Self.missCount(in: pixels, leftHalf: true, isBlack: true) == 0)
        #expect(Self.missCount(in: pixels, leftHalf: false, isBlack: false) == 0)
    }

    @Test(arguments: [199, 300, 404])
    func whenStatusIsNotSuccess_shouldThrowUnacceptableStatus(statusCode: Int) async {
        URLProtocolStub.answer = .response(statusCode: statusCode, data: png)
        let sut = BarcodeLoader.urlSession(URLProtocolStub.session())

        await #expect(throws: BarcodeLoader.LoadingError.unacceptableStatus) {
            _ = try await sut.load(URLRequest(url: url))
        }
    }

    @Test(arguments: [200, 299])
    func whenStatusIsSuccess_shouldReturnImage(statusCode: Int) async throws {
        URLProtocolStub.answer = .response(statusCode: statusCode, data: png)
        let sut = BarcodeLoader.urlSession(URLProtocolStub.session())

        let image = try await sut.load(URLRequest(url: url))

        #expect(image.cgImage.width == TwoToneImage.side)
    }

    @Test
    func whenBytesAreNotAnImage_shouldThrowUndecodable() async {
        URLProtocolStub.answer = .response(statusCode: 200, data: Data("not an image".utf8))
        let sut = BarcodeLoader.urlSession(URLProtocolStub.session())

        await #expect(throws: BarcodeLoader.LoadingError.undecodable) {
            _ = try await sut.load(URLRequest(url: url))
        }
    }

    @Test
    func whenSessionFails_shouldThrowTransportFailed() async {
        URLProtocolStub.answer = .failure(URLError(.notConnectedToInternet))
        let sut = BarcodeLoader.urlSession(URLProtocolStub.session())

        await #expect(throws: BarcodeLoader.LoadingError.transportFailed) {
            _ = try await sut.load(URLRequest(url: url))
        }
    }

    @Test
    func whenRequestCarriesHeader_shouldSendHeaderToSession() async throws {
        URLProtocolStub.answer = .response(statusCode: 200, data: png)
        let sut = BarcodeLoader.urlSession(URLProtocolStub.session())
        var request = URLRequest(url: url)
        request.setValue("example-value", forHTTPHeaderField: "X-Example-Header")

        _ = try await sut.load(request)

        let sent = try #require(URLProtocolStub.lastRequest)
        #expect(sent.value(forHTTPHeaderField: "X-Example-Header") == "example-value")
    }

    @Test
    func whenResponseIsNotHTTP_shouldReturnImage() async throws {
        let dataURL = try #require(URL(string: "data:image/png;base64,\(png.base64EncodedString())"))
        let sut = BarcodeLoader.urlSession(URLSession(configuration: .ephemeral))

        let image = try await sut.load(URLRequest(url: dataURL))

        #expect(image.cgImage.width == TwoToneImage.side)
    }
}
#endif
