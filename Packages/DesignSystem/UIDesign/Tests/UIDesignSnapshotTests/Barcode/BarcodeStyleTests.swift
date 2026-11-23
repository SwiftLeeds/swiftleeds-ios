#if os(iOS)
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite
struct BarcodeStyleTests {
    /// A style that draws its own text and ignores the barcode's content.
    private struct TextBarcodeStyle: BarcodeStyle {
        @MainActor
        func makeBody(configuration: Configuration) -> some View {
            Text(BarcodeStyleTests.styleText)
        }
    }

    /// A style that draws the name of the color scheme it reads from the environment, such as "dark".
    private struct SchemeBarcodeStyle: BarcodeStyle {
        /// The color scheme this style reads.
        @Environment(\.colorScheme) private var colorScheme

        @MainActor
        func makeBody(configuration: Configuration) -> some View {
            Text(String(describing: colorScheme))
        }
    }

    /// The words a style draws in place of a barcode's content.
    private static let styleText = "Drawn by the style"

    /// The text the code carries, made up.
    private static let text = "ti_ExampleTicket0000000000"

    @Test
    func whenStyleIsSet_shouldDrawThatStylesBody() throws {
        let code = try QRCode(Self.text)
        let view = Barcode(code, label: Text("Ticket QR code")).barcodeStyle(TextBarcodeStyle())
        let elements = try AccessibilityTree.elements(of: view)
        #expect(elements.map(\.label) == [Self.styleText])
    }

    @Test(arguments: ColorScheme.allCases)
    func whenStyleReadsColorScheme_shouldDrawThatScheme(colorScheme: ColorScheme) throws {
        let code = try QRCode(Self.text)
        let view = Barcode(code, label: Text("Ticket QR code"))
            .barcodeStyle(SchemeBarcodeStyle())
            .environment(\.colorScheme, colorScheme)
        let elements = try AccessibilityTree.elements(of: view)
        #expect(elements.map(\.label) == [String(describing: colorScheme)])
    }
}
#endif
