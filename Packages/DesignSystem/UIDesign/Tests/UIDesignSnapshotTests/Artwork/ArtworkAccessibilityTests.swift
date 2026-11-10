#if os(iOS)
import SFSafeSymbols
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite
struct ArtworkAccessibilityTests {
    @Test
    func whenArtworkSitsBesideText_shouldExposeOnlyTextElement() throws {
        let elements = try AccessibilityTree.elements(
            of: HStack {
                Artwork(icon: Icon(.hammerFill), palette: .teal)
                Text("Building Accessible Apps")
            }
        )
        #expect(elements.count == 1)
        let element = try #require(elements.first)
        #expect(element.label == "Building Accessible Apps")
        #expect(element.traits == .staticText)
    }

    @Test
    func whenLoadingArtworkSitsBesideText_shouldExposeOnlyTextElement() throws {
        let elements = try AccessibilityTree.elements(
            of: HStack {
                Artwork(icon: Icon(.hammerFill), palette: .teal)
                    .redacted(reason: .placeholder)
                Text("Building Accessible Apps")
            }
        )
        #expect(elements.count == 1)
        let element = try #require(elements.first)
        #expect(element.label == "Building Accessible Apps")
        #expect(element.traits == .staticText)
    }

    @Test
    func whenUnhiddenSymbolSitsBesideText_shouldAddSymbolElement() throws {
        let elements = try AccessibilityTree.elements(
            of: HStack {
                Image(icon: Icon(.hammerFill))
                Text("Building Accessible Apps")
            }
        )
        #expect(elements.count == 2)
    }
}
#endif
