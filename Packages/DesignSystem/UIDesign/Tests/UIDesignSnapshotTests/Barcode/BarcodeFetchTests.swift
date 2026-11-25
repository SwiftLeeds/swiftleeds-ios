#if os(iOS)
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite
struct BarcodeFetchTests {
    /// A style that draws a word beside the barcode's content.
    private struct StyledBarcodeStyle: BarcodeStyle {
        /// Creates a view that represents the body of a barcode.
        ///
        /// - Parameter configuration: The properties of the barcode.
        /// - Returns: A view that represents the body of a barcode.
        @MainActor
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                Text(BarcodeFetchTests.styleWord)
                configuration.content
            }
        }
    }

    /// The label the caller gives the barcode.
    private static let label = "Ticket QR code"

    /// The words the placeholder draws.
    private static let placeholderText = "Loading the code"

    /// The words the fallback draws.
    private static let fallbackText = "No code to show"

    /// The word the test style draws beside the content.
    private static let styleWord = "Styled"

    /// The text the code carries, made up.
    private static let text = "ti_ExampleTicket0000000000"

    /// Returns a barcode in the given phase, with a placeholder and a fallback of its own.
    ///
    /// - Parameter phase: The phase of the load to draw.
    /// - Returns: The barcode, drawn in the test style.
    private static func barcode(in phase: BarcodeLoadingPhase) -> some View {
        Barcode(
            phase: phase,
            label: Text(label),
            placeholder: { Text(placeholderText) },
            fallback: { Text(fallbackText) },
        )
        .barcodeStyle(StyledBarcodeStyle())
    }

    /// Returns a phase that holds the marks of a made-up code.
    ///
    /// - Returns: The success phase.
    /// - Throws: When the code, its image or its marks cannot be made.
    private static func successPhase() throws -> BarcodeLoadingPhase {
        .success(try SuppliedBarcodeImage(LightBlueCodeImage.make(carrying: text)))
    }

    @Test
    func whenPhaseSucceeds_shouldExposeImageElementWithLabel() throws {
        let sut = Self.barcode(in: try Self.successPhase())
        let elements = try AccessibilityTree.elements(of: sut)
        let image = try #require(elements.first { $0.label == Self.label })
        #expect(image.traits.contains(.image))
        #expect(elements.count { $0.label == Self.label } == 1)
    }

    @Test
    func whenPhaseSucceeds_shouldDrawStyle() throws {
        let sut = Self.barcode(in: try Self.successPhase())
        let labels = try AccessibilityTree.elements(of: sut).map(\.label)
        #expect(labels.contains(Self.styleWord), "\(labels) does not hold the style's word")
    }

    @Test
    func whenPhaseFails_shouldExposeOnlyFallbackElement() throws {
        let sut = Self.barcode(in: .failure)
        let labels = try AccessibilityTree.elements(of: sut).map(\.label)
        #expect(labels == [Self.fallbackText])
    }

    @Test
    func whenPhaseIsEmpty_shouldExposeOnlyPlaceholderElement() throws {
        let sut = Self.barcode(in: .empty)
        let labels = try AccessibilityTree.elements(of: sut).map(\.label)
        #expect(labels == [Self.placeholderText])
    }
}
#endif
