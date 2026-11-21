#if os(iOS)
import SwiftUI
import Testing
import UIDesign
import UIKit

/// Tests that a photo at a file URL loads its picture and crops it to its frame.
@MainActor
@Suite
struct PhotoIntegrationTests {
    /// The reason a test could not set up or read a hosted photo.
    private enum ProbeError: Error {
        /// The picture could not be drawn or encoded.
        case noPicture
        /// The picture did not load into the window in time.
        case neverLoaded
    }

    /// The size of the photo's frame, portrait so the 3:2 picture overflows sideways.
    private static let frame = CGSize(width: 100, height: 150)

    /// The size of the window that hosts the frame, wide so spill shows beside it.
    private static let windowSize = CGSize(width: 300, height: 150)

    /// The color behind the photo, which the picture never uses.
    private static let background = UIColor.white

    /// The largest gap per color component that still counts as the same color.
    private static let tolerance: Float = 4.0 / 255

    /// How long to wait for the picture to load.
    private static let timeout = Duration.seconds(5)

    /// How long to wait between checks for the picture.
    private static let interval = Duration.milliseconds(50)

    /// The frame's rectangle, centered in the window.
    private static var frameRect: CGRect {
        CGRect(
            x: (windowSize.width - frame.width) / 2,
            y: 0,
            width: frame.width,
            height: frame.height,
        )
    }

    /// Writes the sample picture as a PNG to a new file in the temporary directory.
    ///
    /// - Returns: The URL of the file.
    /// - Throws: When the picture cannot be drawn or encoded, or the file cannot be written.
    private static func writeSamplePhoto() throws -> URL {
        let renderer = ImageRenderer(content: Image.samplePhoto)
        renderer.scale = 1
        let png = try #require(renderer.uiImage?.pngData())
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).png")
        try png.write(to: url)
        return url
    }

    /// Hosts a photo of a file in a window, beside empty background.
    ///
    /// - Parameter url: The URL the photo loads from.
    /// - Returns: The window that shows the photo.
    private static func window(showing url: URL) -> UIWindow {
        let content = Photo(url: url)
            .frame(width: frame.width, height: frame.height)
            .frame(width: windowSize.width, height: windowSize.height)
            .ignoresSafeArea()
        let host = UIHostingController(rootView: content)
        host.view.backgroundColor = background
        let window = (SceneFreeWindow() as any WindowMaking).makeWindow(frame: CGRect(origin: .zero, size: windowSize))
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.frame = window.bounds
        host.view.layoutIfNeeded()
        return window
    }

    /// Returns the pixels of what a window shows now, at one pixel to the point.
    ///
    /// - Parameter window: The window to read.
    /// - Returns: The window's pixels.
    /// - Throws: ``ProbeError/noPicture`` when the window draws no image.
    private static func pixels(of window: UIWindow) throws(ProbeError) -> Pixels {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: windowSize, format: format).image { context in
            window.layer.render(in: context.cgContext)
        }
        guard let cgImage = image.cgImage, let pixels = try? Pixels(of: cgImage, scale: 1) else { throw .noPicture }
        return pixels
    }

    /// Reads the window until its frame's center shows the picture's sky, or time runs out.
    ///
    /// - Parameter window: The window to read.
    /// - Returns: The pixels read once the picture had loaded.
    /// - Throws: ``ProbeError/neverLoaded`` when the picture has not loaded within ``timeout``.
    private static func pixelsOnceLoaded(in window: UIWindow) async throws -> Pixels {
        let sky = Image.samplePhotoSky.resolve(in: EnvironmentValues())
        let deadline = ContinuousClock.now + timeout
        while ContinuousClock.now < deadline {
            let pixels = try pixels(of: window)
            let centre = pixels.color(at: CGPoint(x: frameRect.midX, y: frameRect.midY))
            if isClose(centre, to: sky) { return pixels }
            try await Task.sleep(for: interval)
        }
        throw ProbeError.neverLoaded
    }

    /// Returns whether a color is within ``tolerance`` of a UIKit color.
    ///
    /// - Parameters:
    ///   - color: The color to check.
    ///   - expected: The color to compare with.
    /// - Returns: Whether the red, green and blue components each differ by `tolerance` or less.
    private static func isClose(_ color: Color.Resolved, to expected: UIColor) -> Bool {
        isClose(color, to: Color(expected).resolve(in: EnvironmentValues()))
    }

    /// Returns whether a color is within ``tolerance`` of another.
    ///
    /// - Parameters:
    ///   - color: The color to check.
    ///   - expected: The color to compare with.
    /// - Returns: Whether the red, green and blue components each differ by `tolerance` or less.
    private static func isClose(_ color: Color.Resolved, to expected: Color.Resolved) -> Bool {
        abs(color.red - expected.red) <= tolerance
            && abs(color.green - expected.green) <= tolerance
            && abs(color.blue - expected.blue) <= tolerance
    }

    @Test
    func whenURLPointsToPicture_shouldDrawPictureCroppedToFrame() async throws {
        let url = try Self.writeSamplePhoto()
        defer { try? FileManager.default.removeItem(at: url) }
        let window = Self.window(showing: url)

        let pixels = try await Self.pixelsOnceLoaded(in: window)

        let sky = Image.samplePhotoSky.resolve(in: EnvironmentValues())
        let centre = pixels.color(at: CGPoint(x: Self.frameRect.midX, y: Self.frameRect.midY))
        #expect(Self.isClose(centre, to: sky), "centre \(centre), expected sky \(sky)")

        let forbidden = [Image.samplePhotoLeadingBar, Image.samplePhotoTrailingBar].map {
            $0.resolve(in: EnvironmentValues())
        }
        let inside = pixels.colors(in: Self.frameRect)
        let leaks = inside.filter { color in
            Self.isClose(color, to: Self.background) || forbidden.contains { Self.isClose(color, to: $0) }
        }
        #expect(leaks.isEmpty, "\(leaks.count) pixels inside the frame are background or bar colored")

        let beside = [
            CGRect(x: 0, y: 0, width: Self.frameRect.minX, height: Self.windowSize.height),
            CGRect(x: Self.frameRect.maxX, y: 0, width: Self.frameRect.minX, height: Self.windowSize.height),
        ]
        let spill = beside.flatMap { pixels.colors(in: $0) }.filter { !Self.isClose($0, to: Self.background) }
        #expect(spill.isEmpty, "\(spill.count) pixels beside the frame are not background, so the picture spilled")
    }
}
#endif
