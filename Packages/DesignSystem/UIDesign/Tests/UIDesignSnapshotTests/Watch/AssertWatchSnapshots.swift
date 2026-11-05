#if os(watchOS)
import Foundation
import SnapshotTesting
import SwiftUI
import Testing
import UIDesign
import UIKit
import WatchKit

/// An Apple Watch model that the reference images are recorded for.
struct WatchModel: Equatable, Sendable {
    /// A text size to record, with the name of its reference image.
    fileprivate struct TextSize: Equatable, Hashable, Sendable {
        /// The part of the reference image's file name that tells this text size from the others.
        let name: String

        /// The text size the view renders with.
        let size: DynamicTypeSize
    }

    // swiftlint:disable no_magic_numbers - the measured screen metrics of this model
    /// The Apple Watch SE 3 (40mm), the smallest Watch screen Apple ships.
    ///
    /// Its Text Size setting stops at `accessibility1`.
    static let se3FortyMillimeter = Self(
        name: "40mm",
        screenSize: CGSize(width: 162, height: 197),
        pixelsPerPoint: 2,
        defaultTextSize: .large,
        largestTextSize: .accessibility1,
    )
    // swiftlint:enable no_magic_numbers

    /// The part of each reference image's file name that names this model.
    let name: String

    /// The size of the screen in points.
    let screenSize: CGSize

    /// The pixels drawn for each point.
    let pixelsPerPoint: CGFloat

    /// The text size most people read at on this model.
    let defaultTextSize: DynamicTypeSize

    /// The largest text size this model's Text Size setting offers.
    let largestTextSize: DynamicTypeSize

    /// The text sizes to record: the default one, and the largest this model offers.
    fileprivate var textSizes: [TextSize] {
        [
            TextSize(name: "default", size: defaultTextSize),
            TextSize(name: "largest", size: largestTextSize),
        ]
    }
}

/// Compares `view` with its reference images, rendered with `ImageRenderer`.
///
/// Two images: the default text size and the largest text size the model offers. Each image is the
/// whole screen of `model`, with the view centered. The appearance is dark, the only one the
/// Watch has. A run on a simulator with another screen size records an issue and compares nothing.
///
/// A view that does not fit the height is cut off, so this asks whether the view fits one screen
/// with no scrolling. Give it one realistic composition, with at most three elements across. A
/// view that a platform framework draws, such as a web view or some controls, does not render.
///
/// - Parameters:
///   - view: The view to render.
///   - model: The Watch model whose screen the images show.
///   - fileID: The file identifier of the calling test.
///   - filePath: The path of the calling test file, where the reference images live.
///   - testName: The name of the calling test, which names the reference images.
///   - line: The line of the call, where a failure is reported.
///   - column: The column of the call, where a failure is reported.
@MainActor
func assertSnapshots(
    of view: some View,
    on model: WatchModel = .se3FortyMillimeter,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column,
) {
    let simulatorSize = WKInterfaceDevice.current().screenBounds.size
    guard simulatorSize == model.screenSize else {
        Issue.record("The simulator screen is \(simulatorSize), but the model's is \(model.screenSize).")
        return
    }
    for textSize in model.textSizes {
        guard let png = pngData(of: watchScreen(view, on: model, textSize: textSize.size), on: model) else {
            Issue.record("No image was rendered for the \(textSize.name) text size.")
            continue
        }
        var strategy = Snapshotting<Data, Data>.data
        strategy.pathExtension = "png"
        assertSnapshot(
            of: png,
            as: strategy,
            named: "\(model.name)-\(textSize.name)",
            fileID: fileID,
            file: filePath,
            testName: testName,
            line: line,
            column: column,
        )
    }
}

/// Returns `view` centered on a full-size dark Watch screen.
///
/// - Parameters:
///   - view: The view to place on the screen.
///   - model: The Watch model whose screen size the result takes.
///   - textSize: The text size to render the view with.
/// - Returns: A screen of the model's size on the surface color, in the dark appearance, with the
///   view centered.
@MainActor
private func watchScreen(_ view: some View, on model: WatchModel, textSize: DynamicTypeSize) -> some View {
    view
        .dynamicTypeSize(textSize)
        .frame(width: model.screenSize.width, height: model.screenSize.height)
        .background(.surface)
        .environment(\.colorScheme, .dark)
}

/// Returns the PNG bytes of a rendered view.
///
/// - Parameters:
///   - view: The view to render.
///   - model: The Watch model whose pixel density the image uses.
/// - Returns: The PNG data, or `nil` when the view draws no image.
@MainActor
private func pngData(of view: some View, on model: WatchModel) -> Data? {
    let renderer = ImageRenderer(content: view)
    renderer.scale = model.pixelsPerPoint
    return renderer.uiImage?.pngData()
}
#endif
