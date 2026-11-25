#if os(iOS)
import SwiftUI
import Testing
import UIDesign
import UIDesignTestSupport

@MainActor
@Suite
struct BarcodeStyleTests {
    /// A style that draws its own text and ignores the barcode's content.
    private struct TextBarcodeStyle: BarcodeStyle {
        /// Creates a view that represents the body of a barcode.
        ///
        /// - Parameter configuration: The properties of the barcode.
        /// - Returns: A view that represents the body of a barcode.
        @MainActor
        func makeBody(configuration: Configuration) -> some View {
            Text(BarcodeStyleTests.styleText)
        }
    }

    /// A style that draws the name of the color scheme it reads.
    ///
    /// The name comes from the environment, such as "dark".
    private struct SchemeBarcodeStyle: BarcodeStyle {
        /// The color scheme this style reads.
        @Environment(\.colorScheme) private var colorScheme

        /// Creates a view that represents the body of a barcode.
        ///
        /// - Parameter configuration: The properties of the barcode.
        /// - Returns: A view that represents the body of a barcode.
        @MainActor
        func makeBody(configuration: Configuration) -> some View {
            Text(String(describing: colorScheme))
        }
    }

    /// The words a style draws in place of a barcode's content.
    private static let styleText = "Drawn by the style"

    /// The text the code carries, made up.
    private static let text = BarcodeFixture.qrCode.text

    @Test
    func whenStyleIsSet_shouldDrawThatStylesBody() throws {
        let code = try QRCode(Self.text)
        let sut = Barcode(code, label: Text("Ticket QR code")).barcodeStyle(TextBarcodeStyle())
        let elements = try AccessibilityTree.elements(of: sut)
        #expect(elements.map(\.label) == [Self.styleText])
    }

    @Test(arguments: ColorScheme.allCases)
    func whenStyleReadsColorScheme_shouldDrawThatScheme(colorScheme: ColorScheme) throws {
        let code = try QRCode(Self.text)
        let sut = Barcode(code, label: Text("Ticket QR code"))
            .barcodeStyle(SchemeBarcodeStyle())
            .environment(\.colorScheme, colorScheme)
        let elements = try AccessibilityTree.elements(of: sut)
        #expect(elements.map(\.label) == [String(describing: colorScheme)])
    }
}
#endif
