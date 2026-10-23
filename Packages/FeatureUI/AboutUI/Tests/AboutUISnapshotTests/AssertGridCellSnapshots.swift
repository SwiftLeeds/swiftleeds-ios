#if os(iOS)
import SnapshotTesting
import SwiftUI
import UIAssets
import UIComponents

/// The screen width of an iPhone, in points.
private let phoneWidth: CGFloat = 390

/// The number of sides the screen padding appears on, leading and trailing.
private let bothSides: CGFloat = 2

/// The About screen's content width on an iPhone: the screen less its horizontal padding.
private let contentWidth: CGFloat = phoneWidth - Padding.screen * bothSides

@MainActor
func assertGridCellSnapshots(
    of view: some View,
    columns: Int,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column,
) {
    assertSnapshots(
        of: view.inGridCell(columns: columns),
        as: snapshotVariants(),
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column,
    )
}

extension View {
    // One cell of a grid with `columns` columns and `Padding.cellGap` between them.
    fileprivate func inGridCell(columns: Int) -> some View {
        let gaps = Padding.cellGap * CGFloat(columns - 1)
        return
            self
            .frame(width: (contentWidth - gaps) / CGFloat(columns))
            .fixedSize(horizontal: false, vertical: true)
            .padding(Padding.screen)
            .background(Color.background)
    }
}
#endif
