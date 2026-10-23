#if os(iOS)
import SnapshotTesting
import SwiftUI

/// The screen width of an iPhone, in points.
private let phoneWidth: CGFloat = 390

/// A screen height that shows the whole About screen, team included, in points.
private let tallScreenHeight: CGFloat = 3_200

/// An iPhone 13 Pro made tall enough to show the whole About screen, team included.
private let tallIPhone = ViewImageConfig(
    safeArea: ViewImageConfig.iPhone13Pro.safeArea,
    size: CGSize(width: phoneWidth, height: tallScreenHeight),
    traits: ViewImageConfig.iPhone13Pro.traits,
)

@MainActor
func assertScreenSnapshots(
    of view: some View,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column,
) {
    assertSnapshots(
        of: view,
        as: snapshotVariants(layout: .device(config: tallIPhone)),
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column,
    )
}
#endif
