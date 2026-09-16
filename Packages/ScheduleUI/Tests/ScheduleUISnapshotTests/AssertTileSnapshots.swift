#if os(iOS)
import DesignKit
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

private let iPhoneScreenWidth: CGFloat = 390

// The width a tile gets on an iPhone: the screen less its horizontal padding.
let fullTileWidth: CGFloat = iPhoneScreenWidth - Padding.screen * 2

@MainActor
func assertTileSnapshots(
    of view: some View,
    width: CGFloat,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    assertSnapshots(
        of: view.tileCard(width: width),
        as: variants(),
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column
    )
}

private extension View {
    func tileCard(width: CGFloat) -> some View {
        self
            .frame(width: width)
            .fixedSize(horizontal: false, vertical: true)
            .padding(Padding.screen)
            .background(Color(.systemBackground))
    }
}

private func variants<V: View>() -> [String: Snapshotting<V, UIImage>] {
    colorSchemes.reduce(into: [:]) { strategies, scheme in
        for textSize in textSizes {
            strategies["\(scheme.name)-\(textSize.name)"] = Snapshotting<AnyView, UIImage>
                .image(traits: .init(traitsFrom: [
                    .init(userInterfaceStyle: scheme.style),
                    .init(displayScale: 1),
                ]))
                .pullback { AnyView($0.dynamicTypeSize(textSize.size)) }
        }
    }
}
#endif
