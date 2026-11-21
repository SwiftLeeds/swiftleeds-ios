#if os(iOS)
import Foundation
import SwiftUI
import Testing
import UIDesign
import UIKit

@MainActor
@Suite
struct PhotoAccessibilityTests {
    /// A way a photo can show, which its caller names for VoiceOver.
    private enum LabeledCase: CaseIterable {
        /// The picture loaded.
        case loaded
        /// The picture is still loading.
        case loading
        /// The picture failed to load.
        case failed
        /// There is no URL.
        case noURL

        /// The photo in this case, named with the recipe the type documents.
        @MainActor var labeledPhoto: some View {
            unlabeledPhoto
                .frame(width: 100, height: 100)
                .accessibilityElement()
                .accessibilityLabel("The main entrance, with a ramp to the left")
                .accessibilityAddTraits(.isImage)
        }

        /// The photo in this case, before the caller names it.
        @MainActor private var unlabeledPhoto: Photo<Text> {
            switch self {
            case .loaded:
                PhotoAccessibilityTests.photo(in: PhotoAccessibilityTests.loaded)

            case .loading:
                PhotoAccessibilityTests.photo(in: .empty)

            case .failed:
                PhotoAccessibilityTests.photo(in: PhotoAccessibilityTests.failed)

            case .noURL:
                Photo(url: nil) { Text("Fallback") }
            }
        }
    }

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

    @Test(arguments: LabeledCase.allCases)
    private func whenCallerLabelsPhoto_shouldReadOneImageElementWithCallersLabel(labeledCase: LabeledCase) throws {
        let elements = try AccessibilityTree.elements(of: labeledCase.labeledPhoto)
        let element = try #require(elements.first, "no element when \(labeledCase)")
        #expect(elements.count == 1)
        #expect(element.label == "The main entrance, with a ramp to the left")
        #expect(element.traits.contains(.image))
    }
}
#endif
