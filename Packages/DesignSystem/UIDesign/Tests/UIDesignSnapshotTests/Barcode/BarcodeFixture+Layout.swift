#if os(iOS)
import CoreGraphics
import UIDesignTestSupport

/// Where the snapshot tests read each code's render, and the frame it is drawn in.
///
/// Every distance is counted in modules of the stored picture.
extension BarcodeFixture {
    /// Where to read a code's render, in modules of the stored picture.
    struct Layout: Sendable {
        /// The modules across the stored picture, quiet zone included.
        let modulesAcross: Modules

        /// The modules down the stored picture, quiet zone included.
        let modulesDown: Modules

        /// The clear modules the code keeps on each of its four sides.
        let quietZone: Modules

        /// The distance from the leading edge to a module that is dark in the stored picture.
        let darkColumn: Modules

        /// The distance from the top edge to a module that is dark in the stored picture.
        let darkRow: Modules

        /// Creates a layout of a stored picture that is a whole number of modules across.
        ///
        /// - Parameters:
        ///   - modulesAcross: The modules across the stored picture, quiet zone included.
        ///   - modulesDown: The modules down the stored picture, quiet zone included.
        ///   - quietZone: The clear modules the code keeps on each of its four sides.
        ///   - darkColumn: The distance from the leading edge to a module that is dark.
        ///   - darkRow: The distance from the top edge to a module that is dark.
        init(modulesAcross: Int, modulesDown: Modules, quietZone: Modules, darkColumn: Modules, darkRow: Modules) {
            self.modulesAcross = Modules(modulesAcross)
            self.modulesDown = modulesDown
            self.quietZone = quietZone
            self.darkColumn = darkColumn
            self.darkRow = darkRow
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
            // swiftlint:disable:next no_magic_numbers - the QR picture's rows and its finder center, no room for :this
            Layout(modulesAcross: modulesAcross, modulesDown: 37, quietZone: 4, darkColumn: 7.5, darkRow: 7.5)

        case .suppliedLightBlueQRCode:
            // swiftlint:disable:next no_magic_numbers - the same QR picture as the generated code, no room for :this
            Layout(modulesAcross: modulesAcross, modulesDown: 37, quietZone: 4, darkColumn: 7.5, darkRow: 7.5)

        case .aztecCode:
            // swiftlint:disable:next no_magic_numbers - the Aztec picture's rows and bullseye center, no room for :this
            Layout(modulesAcross: modulesAcross, modulesDown: 19, quietZone: 2, darkColumn: 9.5, darkRow: 9.5)

        case .pdf417Barcode:
            // swiftlint:disable:next no_magic_numbers - the PDF417 picture's rows and its first bar, no room for :this
            Layout(modulesAcross: modulesAcross, modulesDown: 31, quietZone: 2, darkColumn: 5.5, darkRow: 15.5)

        case .code128Barcode:
            // swiftlint:disable:next no_magic_numbers - the Code 128 picture's rows and first bar, no room for :this
            Layout(modulesAcross: modulesAcross, modulesDown: 52, quietZone: 10, darkColumn: 10.5, darkRow: 26.5)
        }
    }

    /// The size of the frame the code is drawn in, in points.
    ///
    /// The width is fixed, and the height follows the code's aspect, so the plate fits the code.
    var frameSize: CGSize {
        let height = layout.modulesDown.length(onSideMeasuring: frameWidth, holding: layout.modulesAcross)
        return CGSize(width: frameWidth, height: height)
    }
}
#endif
