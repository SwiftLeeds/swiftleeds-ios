#if os(iOS)
import SnapshotTesting
import SwiftUI
import UIComponents
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

/// The screen width of an iPhone, in points.
private let phoneWidth: CGFloat = 390

/// The number of sides the screen padding appears on, leading and trailing.
private let bothSides: CGFloat = 2

/// The number of columns in the grid the gold and silver sections use.
private let gridColumns: CGFloat = 2

/// The width a tile gets on an iPhone: the screen less its horizontal padding.
let fullTileWidth: CGFloat = phoneWidth - Padding.screen * bothSides

/// The width a tile gets in the two-column grid the gold and silver sections use.
let gridTileWidth: CGFloat = (fullTileWidth - Padding.cellGap) / gridColumns

@MainActor
func assertTileSnapshots(
    of view: some View,
    width: CGFloat,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column,
) {
    assertSnapshots(
        of: view.tileCard(width: width),
        as: variants(),
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column,
    )
}

extension View {
    fileprivate func tileCard(width: CGFloat) -> some View {
        self
            .frame(width: width)
            .fixedSize(horizontal: false, vertical: true)
            .padding(Padding.screen)
            .background(Color(.systemBackground))
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
