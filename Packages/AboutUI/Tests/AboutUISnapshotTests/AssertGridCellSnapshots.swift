#if os(iOS)
import DesignKit
import SharedAssets
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
        of: view.inGridCell(of: columns),
        as: variants(),
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column
    )
}

private extension View {
    // One cell of a grid with `columns` columns and `Padding.cellGap` between them.
    func inGridCell(of columns: Int) -> some View {
        let gaps = Padding.cellGap * CGFloat(columns - 1)
        return self
            .frame(width: (contentWidth - gaps) / CGFloat(columns))
            .fixedSize(horizontal: false, vertical: true)
            .padding(Padding.screen)
            .background(Color.background)
    }
}

@MainActor
private func variants<V: View>() -> [String: Snapshotting<V, UIImage>] {
    colorSchemes.reduce(into: [:]) { strategies, scheme in
        for textSize in textSizes {
            let traits = UITraitCollection { mutable in
                mutable.userInterfaceStyle = scheme.style
                mutable.displayScale = 1
            }
            strategies["\(scheme.name)-\(textSize.name)"] = Snapshotting<AnyView, UIImage>
                .image(traits: traits)
                .pullback { AnyView($0.dynamicTypeSize(textSize.size)) }
        }
    }
}
#endif
