#if os(iOS)
import SnapshotTesting
import SwiftUI
import UIKit

private let colorSchemes: [(name: String, style: UIUserInterfaceStyle)] = [
    ("light", .light),
    ("dark", .dark),
]

private let textSizes: [(name: String, size: DynamicTypeSize)] = [
    ("default", .large),
    ("large", .xxxLarge),
    ("accessibility", .accessibility5),
]

/// Records one reference image of a header for every color scheme and text size.
///
/// The header keeps a free height. Give it a definite one and it never settles:
/// its `GeometryReader` writes a height that feeds back into its own bottom
/// padding. The spacer below it is what brings the title into the image, because
/// the title is an overlay offset past the header's own measured bounds.
@MainActor
func assertHeaderSnapshots(
    of view: some View,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    assertSnapshots(
        of: view.headerCard(),
        as: variants(),
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column
    )
}

private extension View {
    func headerCard(width: CGFloat = 390, titleSpace: CGFloat = 220) -> some View {
        VStack(spacing: 0) {
            self
            Color.clear.frame(height: titleSpace)
        }
        .frame(width: width)
        .background(Color(.systemBackground))
    }
}

// The text size goes on the view, not in the trait collection, matching the
// AuthenticationUI helper this is modelled on.
private func variants<V: View>() -> [String: Snapshotting<V, UIImage>] {
    colorSchemes.reduce(into: [:]) { strategies, scheme in
        for textSize in textSizes {
            strategies["\(scheme.name)-\(textSize.name)"] = Snapshotting<AnyView, UIImage>
                .image(traits: .init(userInterfaceStyle: scheme.style))
                .pullback { AnyView($0.dynamicTypeSize(textSize.size)) }
        }
    }
}
#endif
