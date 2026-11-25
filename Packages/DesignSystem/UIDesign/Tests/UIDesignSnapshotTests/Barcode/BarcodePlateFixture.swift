#if os(iOS)
import CoreGraphics
import UIDesign

/// A kind of code the plate tests draw, with the made-up text it carries and where to read its render.
///
/// Every distance is counted in modules of the stored picture, which spends ten pixels on each.
enum BarcodePlateFixture: CaseIterable, Sendable {
    /// Where to read a code's render, counted in modules of the stored picture.
    struct Layout: Sendable {
        /// The modules across the stored picture, quiet zone included.
        let modulesAcross: Int

        /// The modules down the stored picture, quiet zone included.
        let modulesDown: Int

        /// The clear modules the code keeps on each of its four sides.
        let quietZone: Int

        /// The distance from the leading edge to a module that is dark in the stored picture.
        let darkColumn: Double

        /// The distance from the top edge to a module that is dark in the stored picture.
        let darkRow: Double
    }

    /// A QR code.
    case qrCode

    /// A QR code supplied as an image, drawn light blue on white.
    case suppliedLightBlueQRCode

    /// An Aztec code.
    case aztecCode

    /// A PDF417 barcode.
    case pdf417Barcode

    /// A Code 128 barcode.
    case code128Barcode

    /// The side of a square frame, in points.
    private static let squareSide: CGFloat = 220

    /// The width of a wide frame, in points.
    private static let wideWidth: CGFloat = 320

    /// The made-up text the code carries.
    var text: String {
        switch self {
        case .qrCode: "ti_ExampleTicket0000000000"
        case .suppliedLightBlueQRCode: "ti_ExampleTicket0000000000"
        case .aztecCode: "LOCKER-0042"
        case .pdf417Barcode: "EXAMPLE PASS 0001"
        case .code128Barcode: "ABCD-0001"
        }
    }

    /// The sizes of the stored picture and the module the render poll reads.
    ///
    /// The poll module is the finder's center for a QR code, whether generated or supplied as an
    /// image, the bullseye's center for an Aztec code, and the middle of the first bar of the
    /// start pattern for the two linear codes.
    var layout: Layout {
        switch self {
        case .qrCode:
            // swiftlint:disable:next no_magic_numbers - fixture data
            Layout(modulesAcross: 37, modulesDown: 37, quietZone: 4, darkColumn: 7.5, darkRow: 7.5)

        case .suppliedLightBlueQRCode:
            // swiftlint:disable:next no_magic_numbers - fixture data
            Layout(modulesAcross: 37, modulesDown: 37, quietZone: 4, darkColumn: 7.5, darkRow: 7.5)

        case .aztecCode:
            // swiftlint:disable:next no_magic_numbers - fixture data
            Layout(modulesAcross: 19, modulesDown: 19, quietZone: 2, darkColumn: 9.5, darkRow: 9.5)

        case .pdf417Barcode:
            // swiftlint:disable:next no_magic_numbers - fixture data
            Layout(modulesAcross: 107, modulesDown: 31, quietZone: 2, darkColumn: 5.5, darkRow: 15.5)

        case .code128Barcode:
            // swiftlint:disable:next no_magic_numbers - fixture data
            Layout(modulesAcross: 154, modulesDown: 52, quietZone: 10, darkColumn: 10.5, darkRow: 26.5)
        }
    }

    /// The size of the frame the code is drawn in, in points.
    ///
    /// The width is fixed, and the height follows the code's aspect, so the plate fits the code.
    var frameSize: CGSize {
        let width =
            switch self {
            case .qrCode: Self.squareSide
            case .suppliedLightBlueQRCode: Self.squareSide
            case .aztecCode: Self.squareSide
            case .pdf417Barcode: Self.wideWidth
            case .code128Barcode: Self.wideWidth
            }
        return CGSize(width: width, height: width * CGFloat(layout.modulesDown) / CGFloat(layout.modulesAcross))
    }

    /// Creates the code for this fixture's text.
    ///
    /// - Returns: The code.
    /// - Throws: When the text cannot be encoded.
    func makeContent() throws -> any BarcodeContent {
        switch self {
        case .qrCode: try QRCode(text)
        case .suppliedLightBlueQRCode: try SuppliedBarcodeImage(LightBlueCodeImage.make(carrying: text))
        case .aztecCode: try AztecCode(text)
        case .pdf417Barcode: try PDF417Barcode(text)
        case .code128Barcode: try Code128Barcode(text)
        }
    }
}
#endif
