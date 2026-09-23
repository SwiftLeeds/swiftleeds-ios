#if os(iOS)
import SnapshotTesting
import SwiftUI
import UIKit

/// Compares `view` with its reference images, one per appearance and text size.
///
/// Six images: light and dark, each at the default, the largest standard and the largest
/// accessibility text size.
@MainActor
func assertSnapshots(
    of view: some View,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    assertSnapshots(
        of: view,
        as: variants(width: nil, textSizes: everyTextSize),
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column
    )
}

/// Compares `view` with its reference images at the narrowest screen we design for.
///
/// Four images: light and dark, each at the default and the largest accessibility text size.
///
/// Give it what the smallest screen would really hold: one thing and its label. That screen shows
/// only what is vital, so a row of several items is not a compact design and does not belong in a
/// compact check. A view wider than the frame is centered and cropped at both ends, which hides
/// the very thing the check is for.
@MainActor
func assertCompactSnapshots(
    of view: some View,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    assertSnapshots(
        of: view,
        as: variants(width: compactWidth, textSizes: [everyTextSize[0], everyTextSize[2]]),
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column
    )
}

// A 40mm Apple Watch, the narrowest screen Apple ships.
private let compactWidth: CGFloat = 162

private let colorSchemes: [(name: String, style: UIUserInterfaceStyle)] = [
    ("light", .light),
    ("dark", .dark),
]

private let everyTextSize: [(name: String, size: DynamicTypeSize)] = [
    ("default", .large),
    ("large", .xxxLarge),
    ("accessibility", .accessibility5),
]

// Both of these clip the image if dropped.
// Text size goes on the view: as a trait it renders large but measures small.
// fixedSize is needed: the strategy measures with a zero proposal, which gives the minimum size.
@MainActor
private func variants<V: View>(
    width: CGFloat?,
    textSizes: [(name: String, size: DynamicTypeSize)]
) -> [String: Snapshotting<V, UIImage>] {
    let prefix = width == nil ? "" : "compact-"
    return colorSchemes.reduce(into: [:]) { strategies, scheme in
        for textSize in textSizes {
            strategies["\(prefix)\(scheme.name)-\(textSize.name)"] = Snapshotting<AnyView, UIImage>
                .image(traits: UITraitCollection { $0.userInterfaceStyle = scheme.style })
                .pullback { AnyView(sized($0.dynamicTypeSize(textSize.size), width: width)) }
        }
    }
}

@ViewBuilder
private func sized(_ view: some View, width: CGFloat?) -> some View {
    if let width {
        view.frame(width: width).fixedSize(horizontal: false, vertical: true)
    } else {
        view.fixedSize()
    }
}
#endif
