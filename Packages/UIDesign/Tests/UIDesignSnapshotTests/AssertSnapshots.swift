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
/// It asks one question: at the narrowest width we design for, does this component still say what
/// it is for, without losing anything?
///
/// Give it one realistic composition, not a row of samples. A view wider than the frame is
/// centered and cropped at *both* ends, which hides the very failure the check exists to catch.
/// Apple allows at most three elements across a watch screen, each at least 44 points.
///
/// This is not a watch simulation. This package does not build for watchOS, which has no light
/// appearance and stops at AX3. The width is borrowed from a watch; nothing else is.
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

/// The width of a list row on the narrowest phone we design for.
///
/// A view that fills the width it is given needs one, or the helper renders it
/// at its natural width and no line ever wraps.
let rowWidth = narrowestPhoneWidth - listMargin * 2

// The screen width of an iPhone SE.
private let narrowestPhoneWidth: CGFloat = 375

// The space a list leaves on each side of a row.
private let listMargin: CGFloat = 16

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
