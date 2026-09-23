#if os(macOS)
import AppKit
import SnapshotTesting
import SwiftUI
import Testing

/// Compares `view` with its reference images, one per appearance.
///
/// Two images: light and dark. macOS has no Dynamic Type, so text size is not varied.
///
/// - Parameter view: The view to snapshot.
@MainActor
func assertSnapshots(
    of view: some View,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    assert(
        view,
        width: nil,
        prefix: "",
        at: Origin(fileID: fileID, filePath: filePath, testName: testName, line: line, column: column)
    )
}

/// Compares `view` with its reference images at the narrowest screen we design for.
///
/// Two images: light and dark. Use this for a component. A reference sheet does not need it.
///
/// - Parameter view: The view to snapshot.
@MainActor
func assertCompactSnapshots(
    of view: some View,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    assert(
        view,
        width: compactWidth,
        prefix: "compact-",
        at: Origin(fileID: fileID, filePath: filePath, testName: testName, line: line, column: column)
    )
}

// A 40mm Apple Watch, the narrowest screen Apple currently ships. Matches the iOS helper.
private let compactWidth: CGFloat = 162

private let appearances: [(label: String, name: NSAppearance.Name)] = [
    ("light", .aqua),
    ("dark", .darkAqua),
]

// Where the test called from. Carried as one value so it does not crowd every signature.
private struct Origin {
    let fileID: StaticString
    let filePath: StaticString
    let testName: String
    let line: UInt
    let column: UInt
}

@MainActor
private func assert(_ view: some View, width: CGFloat?, prefix: String, at origin: Origin) {
    for appearance in appearances {
        guard let named = NSAppearance(named: appearance.name) else {
            Issue.record("The system does not offer the \(appearance.label) appearance.")
            continue
        }
        assertSnapshot(
            of: host(view, width: width, in: named),
            as: .image,
            named: "\(prefix)\(appearance.label)",
            fileID: origin.fileID,
            file: origin.filePath,
            testName: origin.testName,
            line: origin.line,
            column: origin.column
        )
    }
}

// The library has no strategy for a SwiftUI view on macOS, so host it first.
//
// The appearance is set before measuring, so a size that depends on it is the size drawn.
// `fixedSize` matches the iOS helper, so both platforms snapshot the same geometry.
@MainActor
private func host(
    _ view: some View,
    width: CGFloat?,
    in appearance: NSAppearance
) -> NSHostingView<some View> {
    let hosting = NSHostingView(rootView: sized(view, width: width))
    hosting.appearance = appearance
    hosting.layoutSubtreeIfNeeded()
    hosting.frame = CGRect(origin: .zero, size: hosting.fittingSize)
    hosting.layoutSubtreeIfNeeded()
    return hosting
}

// A width of nil means the view chooses its own. A width pins it, and only height stays ideal.
@ViewBuilder
private func sized(_ view: some View, width: CGFloat?) -> some View {
    if let width {
        view.frame(width: width).fixedSize(horizontal: false, vertical: true)
    } else {
        view.fixedSize()
    }
}
#endif
