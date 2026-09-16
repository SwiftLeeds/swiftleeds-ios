#if os(iOS)
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

@MainActor
func assertScreenSnapshots(
    of view: some View,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    assertSnapshots(
        of: view,
        as: variants(),
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column
    )
}

private func variants<V: View>() -> [String: Snapshotting<V, UIImage>] {
    colorSchemes.reduce(into: [:]) { strategies, scheme in
        for textSize in textSizes {
            strategies["\(scheme.name)-\(textSize.name)"] = Snapshotting<AnyView, UIImage>
                .image(
                    layout: .device(config: .iPhone13Pro),
                    traits: .init(traitsFrom: [
                        .init(userInterfaceStyle: scheme.style),
                        .init(displayScale: 1),
                    ])
                )
                .pullback { AnyView($0.dynamicTypeSize(textSize.size)) }
        }
    }
}
#endif
