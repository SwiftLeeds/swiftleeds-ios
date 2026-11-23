#if os(iOS)
import SwiftUI
import Testing
import UIDesign

/// Tests what a logo adds to the accessibility tree.
@MainActor
@Suite
struct LogoAccessibilityTests {
    /// A way a logo can stand while its fallback text is on screen.
    enum Standing: CaseIterable {
        /// The caller provided no URL.
        case noURL

        /// The mark failed to load.
        case failed
    }

    /// A load failure with no detail, for a phase that is a failure.
    private struct SampleLoadError: Error {}

    /// The name shown beside a logo.
    private static let label = "Example Co"

    /// The words the fallback draws.
    private static let fallbackText = "Fallback"

    /// Returns a logo in one standing, with a text fallback.
    ///
    /// - Parameter standing: The standing to put the logo in.
    /// - Returns: The logo, with no accessibility modifier of the caller's.
    @ViewBuilder
    private func logo(in standing: Standing) -> some View {
        switch standing {
        case .noURL:
            Logo(url: nil) { Text(Self.fallbackText) }

        case .failed:
            Logo(phase: .failure(SampleLoadError())) { Text(Self.fallbackText) }
        }
    }

    @Test
    func whenFailedLogoSitsBesideName_shouldExposeOnlyName() throws {
        let view = HStack {
            Logo(phase: .failure(SampleLoadError())) { Text(Self.fallbackText) }
            Text(Self.label)
        }
        let elements = try AccessibilityTree.elements(of: view)
        #expect(elements.map(\.label) == [Self.label])
    }

    @Test(arguments: Standing.allCases)
    func whenLogoWithTextFallbackIsNotNamed_shouldExposeNoElement(standing: Standing) throws {
        let elements = try AccessibilityTree.elements(of: logo(in: standing))
        #expect(elements.isEmpty, "The logo exposed \(elements.map(\.label))")
    }
}
#endif
