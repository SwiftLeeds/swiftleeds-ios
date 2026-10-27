#if os(iOS)
import SwiftUI
import Testing
import UIDesign
import UIKit

/// Tests that a hosted `.surface` resolves as elevated inside an elevated container.
@MainActor
@Suite
struct BrandSurfaceHostingTests {
    /// The reason a test could not read a color.
    private enum ProbeError: Error {
        /// SwiftUI never evaluated the hosted view, so it resolved no color.
        case neverResolved
    }

    /// A maker of a window for a hosted view.
    @MainActor
    private protocol WindowMaking {
        /// Returns a window that fills a frame.
        ///
        /// - Parameter frame: The frame of the window.
        /// - Returns: The window.
        func makeWindow(frame: CGRect) -> UIWindow
    }

    /// A maker of a window with no window scene, because the test bundle has none.
    @MainActor
    private struct SceneFreeWindow: WindowMaking {
        /// Returns a window with no window scene that fills a frame.
        ///
        /// - Parameter frame: The frame of the window.
        /// - Returns: The window.
        @available(iOS, deprecated: 26.0, message: "Only for a test bundle with no window scene")
        func makeWindow(frame: CGRect) -> UIWindow {
            UIWindow(frame: frame)
        }
    }

    /// A place for the hosted view to leave the color it resolved.
    private final class Receipt {
        /// The color the hosted view resolved, or `nil` before SwiftUI evaluates it.
        var color: Color.Resolved?
    }

    /// A view that resolves the `.surface` token in its own environment and records the result.
    private struct SurfaceProbe: View {
        /// Where the resolved color is recorded.
        let receipt: Receipt

        /// The environment SwiftUI passes to this view when UIKit hosts it.
        @Environment(\.self) private var environment

        /// A view with no content that records the resolved surface.
        var body: some View {
            receipt.color = BrandShapeStyle.surface.resolve(in: environment).resolve(in: environment)
            return Color.clear
        }
    }

    /// The side of the square window the view is hosted in, in points.
    private static let side: CGFloat = 40
    /// The largest gap per color component that still counts as the same color.
    private static let tolerance: Float = 2.0 / 255

    /// Hosts the `.surface` probe in a dark, elevated container and returns what it resolved.
    ///
    /// - Parameter brand: The brand the view reads from its environment.
    /// - Returns: The color SwiftUI resolved for `.surface` inside the host.
    /// - Throws: ``ProbeError/neverResolved`` when SwiftUI does not evaluate the hosted view.
    private static func resolvedSurface(of brand: Brand) throws(ProbeError) -> Color.Resolved {
        let receipt = Receipt()
        let host = UIHostingController(rootView: SurfaceProbe(receipt: receipt).environment(\.brand, brand))
        host.traitOverrides.userInterfaceStyle = .dark
        host.traitOverrides.userInterfaceLevel = .elevated
        let frame = CGRect(x: 0, y: 0, width: side, height: side)
        let window = (SceneFreeWindow() as any WindowMaking).makeWindow(frame: frame)
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.frame = frame
        host.view.layoutIfNeeded()
        guard let color = receipt.color else { throw .neverResolved }
        return color
    }

    /// Returns whether every component of two colors is within ``tolerance``.
    ///
    /// - Parameters:
    ///   - first: One of the colors.
    ///   - second: The other color.
    /// - Returns: Whether the red, green and blue components each differ by `tolerance` or less.
    private static func isClose(_ first: Color.Resolved, to second: Color.Resolved) -> Bool {
        abs(first.red - second.red) <= tolerance
            && abs(first.green - second.green) <= tolerance
            && abs(first.blue - second.blue) <= tolerance
    }

    /// Checks that a hosted `.surface` resolves to the elevated color, not the base color.
    ///
    /// - Parameter brand: The brand to check.
    /// - Throws: ``ProbeError/neverResolved`` when SwiftUI does not evaluate the hosted view.
    @Test(arguments: Brand.allCases)
    func whenHostedInElevatedDarkContainer_shouldResolveElevatedSurface(brand: Brand) throws {
        let resolved = try Self.resolvedSurface(of: brand)
        let elevated = WCAG.resolve(brand.surface, in: .darkElevated)
        let base = WCAG.resolve(brand.surface, in: .dark)
        #expect(
            Self.isClose(resolved, to: elevated),
            "\(brand): resolved \(resolved), expected elevated \(elevated), base is \(base)",
        )
        #expect(
            !Self.isClose(resolved, to: base),
            "\(brand): resolved the base surface \(resolved), elevated is \(elevated)",
        )
    }
}
#endif
