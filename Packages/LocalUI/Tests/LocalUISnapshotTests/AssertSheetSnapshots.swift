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

// The width the sheet's content gets on an iPhone: the screen less its horizontal padding.
private let sheetContentWidth: CGFloat = 390 - Padding.screen * 2

@MainActor
func assertSheetSnapshots(
    of view: some View,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    assertSnapshots(
        of: view.onSheet(),
        as: variants(),
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column
    )
}

private extension View {
    func onSheet() -> some View {
        self
            .frame(width: sheetContentWidth)
            .fixedSize(horizontal: false, vertical: true)
            .padding(Padding.screen)
            .background(Color.background)
    }
}

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
