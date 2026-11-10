#if os(iOS)
import Foundation
import SwiftUI
import UIKit

/// A reader of the accessibility elements that a hosted SwiftUI view exposes.
@MainActor
enum AccessibilityTree {
    /// One accessibility element read from a hosted view.
    struct Element: Equatable {
        /// The label that VoiceOver reads, or `nil` when the element has none.
        let label: String?
        /// The value that VoiceOver reads after the label, or `nil` when the element has none.
        let value: String?
        /// The traits that describe the element.
        let traits: UIAccessibilityTraits
    }

    /// The reason the accessibility switch could not be turned on.
    enum SwitchOnError: Error, Equatable {
        /// The system accessibility library did not load.
        case libraryNotLoaded
        /// The library loaded, but it has no function with this name.
        case functionMissing(String)
    }

    /// A C function that turns one accessibility setting on or off.
    private typealias Setter = @convention(c) (Bool) -> Void

    /// The path of the system library that holds the switch functions.
    private static let libraryPath = "/usr/lib/libAccessibility.dylib"
    /// The names of the functions that turn accessibility on.
    private static let switchFunctionNames = [
        "_AXSSetAutomationEnabled",
        "_AXSApplicationAccessibilitySetEnabled",
    ]
    /// The side of the square window the view is hosted in, in points.
    private static let side: CGFloat = 400
    /// How long the run loop spins, in seconds, so SwiftUI can build its accessibility tree.
    private static let settleTime: TimeInterval = 0.3
    /// The deepest level of the tree that the walk visits.
    private static let maximumDepth = 30

    /// Turns accessibility on for the whole test process.
    ///
    /// The switch is process-wide. It stays on for the rest of the test run. Without it,
    /// a hosted SwiftUI view exposes no elements.
    ///
    /// - Throws: ``SwitchOnError/libraryNotLoaded`` when the library does not load.
    ///   ``SwitchOnError/functionMissing(_:)`` when the library lacks one of the functions.
    private static func switchOn() throws(SwitchOnError) {
        guard let library = dlopen(libraryPath, RTLD_NOW) else { throw .libraryNotLoaded }
        for name in switchFunctionNames {
            guard let function = dlsym(library, name) else { throw .functionMissing(name) }
            unsafeBitCast(function, to: Setter.self)(true)
        }
    }

    /// Hosts a view in a window and reads the accessibility elements it exposes.
    ///
    /// - Parameter view: The view to read.
    /// - Returns: The elements, in the order the hierarchy lists them.
    /// - Throws: ``SwitchOnError`` when accessibility cannot be turned on.
    static func elements(of view: some View) throws(SwitchOnError) -> [Element] {
        try switchOn()
        let host = UIHostingController(rootView: view)
        let frame = CGRect(x: 0, y: 0, width: side, height: side)
        let window = (SceneFreeWindow() as any WindowMaking).makeWindow(frame: frame)
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.frame = frame
        host.view.layoutIfNeeded()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: settleTime))
        host.view.layoutIfNeeded()
        var elements: [Element] = []
        walk(host.view, depth: 0, into: &elements)
        return elements
    }

    /// Appends the accessibility elements at or below an object, in the order the hierarchy lists them.
    ///
    /// - Parameters:
    ///   - object: The object to start from.
    ///   - depth: How many levels the walk has already gone down.
    ///   - elements: The list that receives each element found.
    private static func walk(_ object: NSObject, depth: Int, into elements: inout [Element]) {
        guard depth < maximumDepth else { return }
        if object.isAccessibilityElement {
            elements.append(
                Element(
                    label: object.accessibilityLabel,
                    value: object.accessibilityValue,
                    traits: object.accessibilityTraits,
                )
            )
            return
        }
        for child in children(of: object) {
            walk(child, depth: depth + 1, into: &elements)
        }
    }

    /// Returns the objects that one level below an object holds, in the order the hierarchy lists them.
    ///
    /// - Parameter object: The object to read.
    /// - Returns: The declared accessibility elements. Otherwise the indexed elements.
    ///   Otherwise the subviews of a view.
    private static func children(of object: NSObject) -> [NSObject] {
        if let declared = object.accessibilityElements, !declared.isEmpty {
            return declared.compactMap { $0 as? NSObject }
        }
        let count = object.accessibilityElementCount()
        if count != NSNotFound, count > 0 {
            return (0..<count).compactMap { object.accessibilityElement(at: $0) as? NSObject }
        }
        return (object as? UIView)?.subviews ?? []
    }
}
#endif
