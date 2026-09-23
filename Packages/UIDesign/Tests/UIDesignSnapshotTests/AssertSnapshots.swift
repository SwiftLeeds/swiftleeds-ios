#if os(iOS)
import SnapshotTesting
import SwiftUI
import UIKit

/// Compares `view` with its reference images, one per appearance and text size.
///
/// Six images: light and dark, each at the default, the largest standard and the largest
/// accessibility text size.
///
/// - Parameter view: The view to snapshot.
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
/// Use this for a component. A reference sheet does not need it.
///
/// - Parameter view: The view to snapshot.
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

// A 40mm Apple Watch, the narrowest screen Apple currently ships. We design for it first, so a
// component that survives here survives a folded phone and a widget too.
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

// Two traps, both measured, both ending in a clipped image.
//
// 1. A text size passed as a trait renders large but measures small, so put it on the view.
// 2. The strategy measures with a zero proposal, which returns the smallest size the view can
//    take rather than the size it wants. `fixedSize` makes the two the same.
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

// A width of nil means the view chooses its own. A width pins it, and only height stays ideal.
@ViewBuilder
private func sized(_ view: some View, width: CGFloat?) -> some View {
    if let width {
        view.frame(width: width).fixedSize(horizontal: false, vertical: true)
    } else {
        view.fixedSize()
    }
}
#endif
