#if os(iOS)
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign
import UIDesignTestSupport
import UIKit

@MainActor
@Suite(.snapshots(record: .never)) struct BarcodeSnapshotTests {
    /// The made-up text the code carries.
    private static let text = BarcodeFixture.qrCode.text

    /// The side of the barcode's frame, in points.
    private static let side = BarcodeFixture.qrCode.frameWidth

    /// The made-up text the Aztec code carries.
    private static let aztecText = BarcodeFixture.aztecCode.text

    /// The made-up text the PDF417 barcode carries.
    private static let pdf417Text = BarcodeFixture.pdf417Barcode.text

    /// The made-up text the Code 128 barcode carries.
    private static let code128Text = BarcodeFixture.code128Barcode.text

    /// The width of the frame a wide barcode is drawn in, in points.
    private static let wideWidth = BarcodeFixture.pdf417Barcode.frameWidth

    /// Returns a barcode in its own frame, with room around it, on a grouped surface.
    ///
    /// - Returns: The view to record, or the reason there is no code.
    @ViewBuilder
    private static func specimen() -> some View {
        switch Result(catching: { try QRCode(text) }) {
        case .success(let code):
            Barcode(code, label: Text("Ticket QR code"))
                .frame(width: side, height: side)
                .padding(.lg)
                .background(.groupedSurface)

        case .failure(let error):
            Text("No code: \(String(describing: error))")
        }
    }

    /// Returns a barcode at a given width and its own height, on a grouped surface.
    ///
    /// The height follows the picture's shape, so the plate fits the code on both axes.
    ///
    /// - Parameters:
    ///   - make: Creates the code to draw.
    ///   - label: The accessibility label of the barcode.
    ///   - width: The width of the frame, in points.
    /// - Returns: The view to record, or the reason there is no code.
    @ViewBuilder
    private static func specimen(
        of make: () throws -> any BarcodeContent,
        label: LocalizedStringKey,
        width: CGFloat,
    ) -> some View {
        switch Result(catching: make) {
        case .success(let code):
            Barcode(code, label: Text(label))
                .frame(width: width, height: width * CGFloat(code.cgImage.height) / CGFloat(code.cgImage.width))
                .padding(.lg)
                .background(.groupedSurface)

        case .failure(let error):
            Text("No code: \(String(describing: error))")
        }
    }

    @Test func whenAztecCodeIsDrawnOnGroupedSurface_shouldShowPlateBehindCode() {
        assertContrastSnapshots(
            of: Self.specimen(of: { try AztecCode(Self.aztecText) }, label: "Locker Aztec code", width: Self.side)
        )
    }

    @Test func whenPDF417BarcodeIsDrawnOnGroupedSurface_shouldShowPlateBehindCode() {
        assertContrastSnapshots(
            of: Self.specimen(
                of: { try PDF417Barcode(Self.pdf417Text) },
                label: "Pass PDF417 barcode",
                width: Self.wideWidth,
            )
        )
    }

    @Test func whenCode128BarcodeIsDrawnOnGroupedSurface_shouldShowPlateBehindCode() {
        assertContrastSnapshots(
            of: Self.specimen(
                of: { try Code128Barcode(Self.code128Text) },
                label: "Code 128 barcode",
                width: Self.wideWidth,
            )
        )
    }

    @Test func whenDrawnOnGroupedSurface_shouldDrawCodeOnRoundedPlate() {
        assertContrastSnapshots(of: Self.specimen())
    }

    @Test func whenRedacted_shouldHideCode() {
        assertSpecimenSnapshots(of: Self.specimen().redacted(reason: .placeholder))
    }

    @Test func whenEverySettingIsOn_shouldDrawPlateAndCode() {
        let allSettings = UITraitCollection {
            $0.userInterfaceStyle = .dark
            $0.accessibilityContrast = .high
            $0.legibilityWeight = .bold
        }
        // The snapshot helpers have no Bold variant, so this calls assertSnapshot directly.
        assertSnapshot(
            of: AnyView(Self.specimen().dynamicTypeSize(.accessibility5).fixedSize()),
            as: .image(traits: allSettings),
            named: "dark-increased-contrast-accessibility5-bold",
        )
    }

    @Test func whenAtLargestTextSize_shouldMatchDefaultReferences() {
        let light = UITraitCollection { $0.userInterfaceStyle = .light }
        // The view is built as the contrast helper builds it, so it compares with that reference.
        assertSnapshot(
            of: AnyView(Self.specimen().dynamicTypeSize(.accessibility5).fixedSize()),
            as: .image(traits: light),
            named: "light-default",
            testName: "whenDrawnOnGroupedSurface_shouldDrawCodeOnRoundedPlate()",
        )
    }
}
#endif
