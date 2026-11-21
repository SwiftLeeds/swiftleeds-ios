#if os(iOS)
import SwiftUI
import Testing
import UIDesign
import UIKit

/// Tests what a logo adds to the accessibility tree.
@MainActor
@Suite
struct LogoAccessibilityTests {
    /// A way a logo can stand, with the fallback text shown wherever the fallback draws.
    enum Case: CaseIterable {
        /// The caller provided no URL.
        case noURL

        /// The mark is loading.
        case loading

        /// The mark loaded.
        case loaded

        /// The mark failed to load.
        case failed
    }

    /// A load failure with no detail, for a phase that is a failure.
    private struct SampleLoadError: Error {}

    /// The label a caller gives a logo it names.
    private static let label = "Example Co"

    /// The words the fallback draws.
    private static let fallbackText = "Fallback"

    /// Returns a logo in one case, with a text fallback.
    ///
    /// - Parameter state: The case to put the logo in.
    /// - Returns: The logo, with no accessibility modifier of the caller's.
    private func logo(in state: Case) -> some View {
        switch state {
        case .noURL:
            Logo(url: nil) { Text(Self.fallbackText) }
                .eraseToAnyView()

        case .loading:
            Logo(phase: .empty) { Text(Self.fallbackText) }
                .eraseToAnyView()

        case .loaded:
            Logo(phase: .success(.wideSampleMark)) { Text(Self.fallbackText) }
                .eraseToAnyView()

        case .failed:
            Logo(phase: .failure(SampleLoadError())) { Text(Self.fallbackText) }
                .eraseToAnyView()
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

    @Test(arguments: Case.allCases)
    func whenLogoIsNotNamed_shouldExposeNoElement(state: Case) throws {
        let elements = try AccessibilityTree.elements(of: logo(in: state))
        #expect(elements.isEmpty, "The logo exposed \(elements.map(\.label))")
    }

    @Test(arguments: Case.allCases)
    func whenCallerNamesLogo_shouldExposeOneImageElementWithLabel(state: Case) throws {
        let view = logo(in: state)
            .accessibilityElement()
            .accessibilityLabel(Self.label)
            .accessibilityAddTraits(.isImage)
        let elements = try AccessibilityTree.elements(of: view)
        #expect(elements.map(\.label) == [Self.label])
        let element = try #require(elements.first)
        #expect(element.traits.contains(.image))
    }
}

extension View {
    /// Returns this view as an `AnyView`, so a function can return a different view for each case.
    fileprivate func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
#endif
