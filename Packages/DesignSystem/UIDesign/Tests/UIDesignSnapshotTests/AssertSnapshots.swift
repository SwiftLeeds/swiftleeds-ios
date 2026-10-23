#if os(iOS)
import SnapshotTesting
import SwiftUI
import UIKit

/// Compares `view` with its reference images, one per appearance and text size.
///
/// Six images: light and dark, each at the default, the largest standard and the largest
/// accessibility text size.
@MainActor
func assertSnapshots(
    of view: some View,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column,
) {
    assertSnapshots(
        of: view,
        as: variants(width: nil, appearances: defaultContrastAppearances, textSizes: everyTextSize),
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column,
    )
}

/// Compares `view` with its reference images at the narrowest screen we design for.
///
/// Four images: light and dark, each at the default and the largest accessibility text size.
///
/// It asks one question: at the narrowest width we design for, does this component still say what
/// it is for, without losing anything?
///
/// Give it one realistic composition, not a row of samples. A view wider than the frame is
/// centered and cropped at *both* ends, which hides the very failure the check exists to catch.
/// Apple allows at most three elements across a watch screen, each at least 44 points.
///
/// This is not a watch simulation. This package does not build for watchOS, which has no light
/// appearance and stops at AX3. The width is borrowed from a watch; nothing else is.
@MainActor
func assertCompactSnapshots(
    of view: some View,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column,
) {
    assertSnapshots(
        of: view,
        as: variants(
            width: compactWidth,
            appearances: defaultContrastAppearances,
            textSizes: [defaultTextSize, largestTextSize],
        ),
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column,
    )
}

/// Compares a specimen with its reference images at the default text size.
///
/// Two images: light and dark.
///
/// A specimen lists the values the design system ships. It is not a component,
/// so it answers what a value looks like, never how a layout holds. The text
/// size cannot change a color, an icon or a length, so a variant per size
/// records the same sheet three times.
@MainActor
func assertSpecimenSnapshots(
    of view: some View,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column,
) {
    assertSnapshots(
        of: view,
        as: variants(
            width: nil,
            appearances: defaultContrastAppearances,
            textSizes: [defaultTextSize],
        ),
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column,
    )
}

/// Compares a color specimen with its reference images at the default text size.
///
/// Four images: light and dark, each with and without Increase Contrast.
///
/// Only color has a contrast variant. Increase Contrast can change a color, but not a length
/// or an icon.
@MainActor
func assertColorSpecimenSnapshots(
    of view: some View,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column,
) {
    assertSnapshots(
        of: view,
        as: variants(
            width: nil,
            appearances: defaultContrastAppearances + increasedContrastAppearances,
            textSizes: [defaultTextSize],
        ),
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column,
    )
}

// A 40mm Apple Watch, the narrowest screen Apple ships.
private let compactWidth: CGFloat = 162

/// The width of a list row on the narrowest phone we design for.
///
/// A view that fills the width it is given needs one, or the helper renders it
/// at its natural width and no line ever wraps.
let rowWidth = narrowestPhoneWidth - listMargin * bothSides

// The screen width of an iPhone SE.
private let narrowestPhoneWidth: CGFloat = 375

// The space a list leaves on each side of a row.
private let listMargin: CGFloat = 16

/// The number of sides a list margin appears on, leading and trailing.
private let bothSides: CGFloat = 2

/// One way the system can draw a view, with the name of its reference image.
private struct Appearance {
    /// The part of the reference image name that tells this appearance from the others.
    let name: String

    /// The traits the view renders with.
    let traits: UITraitCollection
}

/// The light and dark appearances, with the system's default contrast.
@MainActor private let defaultContrastAppearances: [Appearance] = [
    Appearance(name: "light", traits: UITraitCollection { $0.userInterfaceStyle = .light }),
    Appearance(name: "dark", traits: UITraitCollection { $0.userInterfaceStyle = .dark }),
]

/// The light and dark appearances, with Increase Contrast turned on.
@MainActor private let increasedContrastAppearances: [Appearance] = [
    Appearance(
        name: "light-increased-contrast",
        traits: UITraitCollection {
            $0.userInterfaceStyle = .light
            $0.accessibilityContrast = .high
        },
    ),
    Appearance(
        name: "dark-increased-contrast",
        traits: UITraitCollection {
            $0.userInterfaceStyle = .dark
            $0.accessibilityContrast = .high
        },
    ),
]

private let everyTextSize: [(name: String, size: DynamicTypeSize)] = [
    defaultTextSize,
    ("large", .xxxLarge),
    largestTextSize,
]

/// The largest accessibility text size, the one that stresses a layout most.
private let largestTextSize: (name: String, size: DynamicTypeSize) = ("accessibility", .accessibility5)

// The size most people read at, and the only one a specimen needs.
private let defaultTextSize: (name: String, size: DynamicTypeSize) = ("default", .large)

/// Returns one image strategy for each appearance and text size, keyed by reference name.
///
/// - Parameters:
///   - width: The width to render at, or `nil` for the view's natural size.
///   - appearances: The appearances to record, one image set each.
///   - textSizes: The text sizes to record in each appearance.
/// - Returns: The strategies, keyed by the name of each reference image.
@MainActor
private func variants<V: View>(
    width: CGFloat?,
    appearances: [Appearance],
    textSizes: [(name: String, size: DynamicTypeSize)],
) -> [String: Snapshotting<V, UIImage>] {
    let prefix = width == nil ? "" : "compact-"
    return appearances.reduce(into: [:]) { strategies, appearance in
        for textSize in textSizes {
            // Both of these clip the image if dropped.
            // Text size goes on the view: as a trait it renders large but measures small.
            // fixedSize is needed: the strategy measures with a zero proposal, which gives the
            // minimum size.
            let name = "\(prefix)\(appearance.name)-\(textSize.name)"
            strategies[name] = Snapshotting<AnyView, UIImage>
                .image(traits: appearance.traits)
                .pullback { AnyView(sized($0.dynamicTypeSize(textSize.size), width: width)) }
        }
    }
}

@ViewBuilder
private func sized(_ view: some View, width: CGFloat?) -> some View {
    if let width {
        view.frame(width: width).fixedSize(horizontal: false, vertical: true)
    } else {
        view.fixedSize()
    }
}
#endif
