#if os(iOS)
import DesignKit
import SharedAssets
import SnapshotTesting
import SwiftUI

// The About screen's content width on an iPhone: the screen less its horizontal padding.
private let contentWidth: CGFloat = 390 - Padding.screen * 2

@MainActor
func assertGridCellSnapshots(
    of view: some View,
    columns: Int,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    assertSnapshots(
        of: view.inGridCell(columns: columns),
        as: snapshotVariants(),
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column
    )
}

private extension View {
    // One cell of a grid with `columns` columns and `Padding.cellGap` between them.
    func inGridCell(columns: Int) -> some View {
        let gaps = Padding.cellGap * CGFloat(columns - 1)
        return self
            .frame(width: (contentWidth - gaps) / CGFloat(columns))
            .fixedSize(horizontal: false, vertical: true)
            .padding(Padding.screen)
            .background(Color.background)
    }
}
#endif
