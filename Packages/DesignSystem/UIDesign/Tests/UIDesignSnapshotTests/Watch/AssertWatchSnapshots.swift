#if os(watchOS)
import Foundation
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign
import UIKit

/// Compares `view` with its reference images, rendered with `ImageRenderer`.
///
/// Two images: the default text size and the largest accessibility text size. Each image is the
/// whole screen of the 40mm Watch, 162 by 197 points, the smallest Apple ships, with the view
/// centered. The appearance is dark, the only one the Watch has.
///
/// A view that does not fit the height is cut off, so this asks whether the view fits one screen
/// with no scrolling. Give it one realistic composition, with at most three elements across. A
/// view that a platform framework draws, such as a web view or some controls, does not render.
///
/// - Parameters:
///   - view: The view to render.
///   - fileID: The file identifier of the calling test.
///   - filePath: The path of the calling test file, where the reference images live.
///   - testName: The name of the calling test, which names the reference images.
///   - line: The line of the call, where a failure is reported.
///   - column: The column of the call, where a failure is reported.
@MainActor
func assertSnapshots(
    of view: some View,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column,
) {
    for textSize in watchTextSizes {
        guard let png = pngData(of: watchScreen(view, textSize: textSize.size)) else {
            Issue.record("No image was rendered for the \(textSize.name) text size.")
            continue
        }
        var strategy = Snapshotting<Data, Data>.data
        strategy.pathExtension = "png"
        assertSnapshot(
            of: png,
            as: strategy,
            named: textSize.name,
            fileID: fileID,
            file: filePath,
            testName: testName,
            line: line,
            column: column,
        )
    }
}

/// A text size to record, with the name of its reference image.
private struct WatchTextSize {
    /// The part of the reference image name that tells this text size from the others.
    let name: String

    /// The text size the view renders with.
    let size: DynamicTypeSize
}

/// The text sizes to record: the one most people read at, and the largest the Watch offers.
private let watchTextSizes = [
    WatchTextSize(name: "default", size: .large),
    WatchTextSize(name: "largest", size: .accessibility3),
]

/// The width of the 40mm Watch screen in points, the narrowest Apple ships.
private let watchScreenWidth: CGFloat = 162

/// The height of the 40mm Watch screen in points, the shortest Apple ships.
private let watchScreenHeight: CGFloat = 197

/// The pixels drawn for each point.
private let watchImageScale: CGFloat = 2

/// Returns `view` centered on a full-size dark Watch screen.
///
/// - Parameters:
///   - view: The view to place on the screen.
///   - textSize: The text size to render the view with.
/// - Returns: A 162 by 197 point screen on the surface color, in the dark appearance, with the
///   view centered.
@MainActor
private func watchScreen(_ view: some View, textSize: DynamicTypeSize) -> some View {
    view
        .dynamicTypeSize(textSize)
        .frame(width: watchScreenWidth, height: watchScreenHeight)
        .background(.surface)
        .environment(\.colorScheme, .dark)
}

/// Returns the PNG bytes of a rendered view.
///
/// - Parameter view: The view to render.
/// - Returns: The PNG data, or `nil` when the view draws no image.
@MainActor
private func pngData(of view: some View) -> Data? {
    let renderer = ImageRenderer(content: view)
    renderer.scale = watchImageScale
    return renderer.uiImage?.pngData()
}
#endif
