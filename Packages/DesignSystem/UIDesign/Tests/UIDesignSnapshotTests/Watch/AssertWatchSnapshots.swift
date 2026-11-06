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

    // swiftlint:disable no_magic_numbers - the measured screen metrics of these models
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

    /// The Apple Watch Series 12 (46mm).
    ///
    /// Its Text Size setting reaches `accessibility3`.
    static let series12FortySixMillimeter = Self(
        name: "46mm",
        screenSize: CGSize(width: 208, height: 248),
        pixelsPerPoint: 2,
        defaultTextSize: .xLarge,
        largestTextSize: .accessibility3,
    )
    // swiftlint:enable no_magic_numbers

    /// The models the helper can match a simulator to.
    static let all: [Self] = [.se3FortyMillimeter, .series12FortySixMillimeter]

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

    /// Returns the model whose screen has the given size and scale.
    ///
    /// - Parameters:
    ///   - screenSize: The size of the screen in points.
    ///   - screenScale: The pixels drawn for each point.
    /// - Returns: The matching model, or `nil` when no model has this screen.
    fileprivate static func matching(screenSize: CGSize, screenScale: CGFloat) -> Self? {
        all.first { $0.screenSize == screenSize && $0.pixelsPerPoint == screenScale }
    }
}

/// Compares `view` with its reference images, rendered with `ImageRenderer`.
///
/// Two images: the default text size and the largest text size the model offers. Each image is the
/// whole screen of the Watch model that matches the simulator, with the view centered. The
/// appearance is dark, the only one the Watch has. A simulator that matches no model records an
/// issue and compares nothing.
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
    let device = WKInterfaceDevice.current()
    let simulatorSize = device.screenBounds.size
    let simulatorScale = device.screenScale
    guard let model = WatchModel.matching(screenSize: simulatorSize, screenScale: simulatorScale) else {
        Issue.record("No Watch model has the simulator's screen: \(simulatorSize) at \(simulatorScale)x.")
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

/// Returns `view` centered on a full-size dark Watch screen, inside the system's side margin.
///
/// - Parameters:
///   - view: The view to place on the screen.
///   - model: The Watch model whose screen size the result takes.
///   - textSize: The text size to render the view with.
/// - Returns: A screen of the model's size on the surface color, in the dark appearance, with the
///   view centered between the system's leading and trailing margins.
@MainActor
private func watchScreen(_ view: some View, on model: WatchModel, textSize: DynamicTypeSize) -> some View {
    view
        .scenePadding(.horizontal)
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
