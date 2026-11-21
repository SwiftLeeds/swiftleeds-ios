#if os(iOS)
import SwiftUI
import Testing
import UIDesign

@MainActor
@Suite
struct AvatarContainerValueTests {
    /// A container that writes the size each of its subviews publishes as one line of text.
    private struct SizeProbe<Content: View>: View {
        /// The views whose published sizes the probe reads.
        let content: Content

        /// Creates a probe that reads the views a builder creates.
        ///
        /// - Parameter content: A content builder that creates the views to read.
        init(@ViewBuilder content: () -> Content) {
            self.content = content()
        }

        var body: some View {
            Group(subviews: content) { subviews in
                Text(summary(of: subviews))
            }
        }

        /// Returns the published sizes as a comma separated list, with "none" for a subview that has no size.
        ///
        /// - Parameter subviews: The subviews to read.
        /// - Returns: One entry for each subview, in order.
        private func summary(of subviews: SubviewsCollection) -> String {
            subviews
                .map { $0.containerValues.avatarSize.map { String(Double(CGFloat($0))) } ?? "none" }
                .joined(separator: ",")
        }
    }

    @Test
    func whenContainerReadsAvatar_shouldFindItsSize() throws {
        let elements = try AccessibilityTree.elements(
            of: SizeProbe {
                Avatar(url: nil, size: .small)
                Avatar(url: nil, size: .large)
                Text("Ada Archer")
            }
        )
        let element = try #require(elements.first)
        #expect(element.label == "28.0,56.0,none")
    }
}
#endif
