#if os(iOS)
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite(.snapshots(record: .never)) struct BarcodeSnapshotTests {
    /// The made-up text the code carries.
    private static let text = "ti_ExampleTicket0000000000"

    /// The side of the barcode's frame, in points.
    private static let side: CGFloat = 220

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

    @Test func whenDrawnOnGroupedSurface_shouldDrawCodeOnRoundedPlate() {
        assertContrastSnapshots(of: Self.specimen())
    }
}
#endif
