#if os(iOS)
import Foundation
import QuartzCore
import SwiftUI
import Testing
import UIDesign
import UIKit

/// Tests that a logo loaded from a URL draws through the public initializer.
@MainActor
@Suite
struct LogoIntegrationTests {
    /// The side of the square frame the logo is hosted in, in points.
    private static let side: CGFloat = 200

    /// How many times the test checks for the loaded mark before it gives up.
    private static let checkLimit = 200

    /// How long to wait between checks for the mark.
    private static let interval = Duration.milliseconds(50)

    /// The largest gap per color component that still counts as the same color.
    private static let tolerance: Float = 4.0 / 255

    /// How far down the frame the probe point above the mark sits, as a fraction of the frame's height.
    ///
    /// The point lies between the tile's inset edge and the top of the fitted mark, so only a mark
    /// that is stretched to the inset reaches it.
    private static let aboveMarkFraction: CGFloat = 0.3

    /// Writes the wide sample mark to a temporary file.
    ///
    /// - Returns: The URL of the PNG file.
    /// - Throws: A `#require` failure when the mark has no PNG form, or the file error of the write.
    private static func writeWideMark() throws -> URL {
        let renderer = ImageRenderer(content: Image.wideSampleMark)
        renderer.scale = 1
        let png = try #require(renderer.uiImage?.pngData(), "The sample mark has no PNG form")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).png")
        try png.write(to: url)
        return url
    }

    /// Draws a window's contents into pixels.
    ///
    /// - Parameter window: The window to draw.
    /// - Returns: The pixels of the window, at one pixel to the point.
    /// - Throws: A `#require` failure when the drawing has no bitmap, or the error `Pixels` throws
    ///   when it cannot read the bitmap.
    private static func pixels(of window: UIWindow) throws -> Pixels {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: window.bounds.size, format: format).image { context in
            window.layer.render(in: context.cgContext)
        }
        let cgImage = try #require(image.cgImage, "The window drew no bitmap")
        return try Pixels(of: cgImage, scale: 1)
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

    /// Resolves a color the way ``Pixels`` reports one.
    ///
    /// - Parameter color: The color to resolve.
    /// - Returns: The resolved color.
    private static func resolved(_ color: Color) -> Color.Resolved {
        color.resolve(in: EnvironmentValues())
    }

    /// Returns whether a pixel shows the color of one of the mark's bars.
    ///
    /// - Parameter pixel: The pixel's color.
    /// - Returns: Whether the pixel matches either bar.
    private static func isBar(_ pixel: Color.Resolved) -> Bool {
        isClose(pixel, to: resolved(Image.wideSampleMarkLeadingBar))
            || isClose(pixel, to: resolved(Image.wideSampleMarkTrailingBar))
    }

    @Test
    func whenURLPointsToWideMark_shouldFitMarkInsideFrame() async throws {
        let markURL = try Self.writeWideMark()
        defer { try? FileManager.default.removeItem(at: markURL) }
        let frame = CGRect(x: 0, y: 0, width: Self.side, height: Self.side)
        let host = UIHostingController(
            rootView: Logo(url: markURL)
                .frame(width: Self.side, height: Self.side)
                .background(Color.white)
                .ignoresSafeArea()
        )
        let window = (SceneFreeWindow() as any WindowMaking).makeWindow(frame: frame)
        defer { window.isHidden = true }
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.frame = frame
        host.view.layoutIfNeeded()

        let leadingBarCenter = CGPoint(x: Self.side / 4, y: Self.side / 2)
        var checks = 0
        var pixels = try Self.pixels(of: window)
        while !Self.isBar(pixels.color(at: leadingBarCenter)), checks < Self.checkLimit {
            try await Task.sleep(for: Self.interval)
            pixels = try Self.pixels(of: window)
            checks += 1
        }

        let leadingBar = Self.resolved(Image.wideSampleMarkLeadingBar)
        #expect(
            Self.isClose(pixels.color(at: leadingBarCenter), to: leadingBar),
            "The leading bar's center is \(pixels.color(at: leadingBarCenter)), expected \(leadingBar)",
        )
        let aboveMark = pixels.color(at: CGPoint(x: Self.side / 4, y: Self.side * Self.aboveMarkFraction))
        #expect(!Self.isBar(aboveMark), "The mark is stretched above its fitted height: \(aboveMark)")
    }
}
#endif
