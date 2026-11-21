#if os(iOS)
import Foundation
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite
struct PhotoAccessibilityTests {
    /// The phase of a picture that loaded.
    private static var loaded: AsyncImagePhase { .success(.samplePhoto) }

    /// The phase of a picture that failed to load.
    private static var failed: AsyncImagePhase { .failure(URLError(.badServerResponse)) }

    /// A photo in one phase, with a word as its fallback.
    ///
    /// - Parameter phase: The phase to draw.
    /// - Returns: The photo.
    private static func photo(in phase: AsyncImagePhase) -> Photo<Text> {
        Photo(phase: phase) { Text("Fallback") }
    }

    /// A photo that its caller names for VoiceOver, with the recipe the type documents.
    ///
    /// - Parameter phase: The phase to draw.
    /// - Returns: The labeled photo.
    private static func labeledPhoto(in phase: AsyncImagePhase) -> some View {
        photo(in: phase)
            .frame(width: 100, height: 100)
            .accessibilityElement()
            .accessibilityLabel("The main entrance, with a ramp to the left")
            .accessibilityAddTraits(.isImage)
    }

    @Test
    func whenPhotoFailsBesideTitle_shouldReadOnlyTitle() throws {
        let view = HStack {
            Self.photo(in: Self.failed).frame(width: 100, height: 100)
            Text("Main Hall")
        }
        let elements = try AccessibilityTree.elements(of: view)
        #expect(elements.map(\.label) == ["Main Hall"])
    }

    @Test
    func whenPhotoIsLoadedBesideTitle_shouldReadOnlyTitle() throws {
        let view = HStack {
            Self.photo(in: Self.loaded).frame(width: 100, height: 100)
            Text("Main Hall")
        }
        let elements = try AccessibilityTree.elements(of: view)
        #expect(elements.map(\.label) == ["Main Hall"])
    }

    @Test(arguments: [("loaded", true), ("failed", false)])
    func whenCallerLabelsPhoto_shouldReadOneImageElementWithCallersLabel(phaseName: String, isLoaded: Bool) throws {
        let view = Self.labeledPhoto(in: isLoaded ? Self.loaded : Self.failed)
        let elements = try AccessibilityTree.elements(of: view)
        let element = try #require(elements.first, "no element in the \(phaseName) phase")
        #expect(elements.count == 1)
        #expect(element.label == "The main entrance, with a ramp to the left")
        #expect(element.traits.contains(.image))
    }
}
#endif
