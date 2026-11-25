#if os(iOS)
import SwiftUI
import Testing
import UIDesignTestSupport
import UIKit

/// A window that draws a view and reads its picture once it shows what a test waits for.
@MainActor
struct HostedRender {
    /// The reason a hosted render gave no usable picture.
    enum RenderingError: Error, Equatable, Hashable, Sendable {
        /// The picture never passed the readiness check.
        case neverReady
    }

    /// The size of the window, in points.
    private let size: CGSize

    /// The appearance the host is drawn in.
    private let appearance: SystemAppearance

    /// The scale of the window picture.
    private let scale: RenderScale

    /// How many times the window is read before the render gives up.
    private let attempts: Int

    /// How long to wait between two reads of the window.
    private let interval: Duration

    /// Creates a render of a window of one size, appearance and scale.
    ///
    /// - Parameters:
    ///   - size: The size of the window, in points.
    ///   - appearance: The appearance the host is drawn in.
    ///   - scale: The scale of the window picture.
    ///   - attempts: How many times the window is read before the render gives up.
    ///   - interval: How long to wait between two reads of the window.
    init(size: CGSize, appearance: SystemAppearance, scale: RenderScale, attempts: Int, interval: Duration) {
        self.size = size
        self.appearance = appearance
        self.scale = scale
        self.attempts = attempts
        self.interval = interval
    }

    /// Returns the picture of a view hosted in a window, read until it is ready.
    ///
    /// The view is drawn under the appearance's style and contrast. The window is read up to
    /// the render's attempts, waiting its interval between two reads.
    ///
    /// - Parameters:
    ///   - content: The view to host.
    ///   - isReady: Returns whether a picture shows what the test waits for.
    /// - Returns: The first picture that `isReady` accepts, at the render's scale.
    /// - Throws: ``RenderingError/neverReady`` when no picture is accepted within the attempts.
    ///   Also whatever `isReady` throws, and when the window's picture cannot be made or the
    ///   task is cancelled while it waits.
    func image(of content: some View, until isReady: (CGImage) throws -> Bool) async throws -> CGImage {
        let host = UIHostingController(rootView: content.ignoresSafeArea())
        // Traits, not `EnvironmentValues`, because the environment cannot set Increase Contrast.
        host.traitOverrides.userInterfaceStyle = appearance.isLight ? .light : .dark
        host.traitOverrides.accessibilityContrast = appearance.withoutIncreasedContrast == nil ? .normal : .high
        let frame = CGRect(origin: .zero, size: size)
        let window = (SceneFreeWindow() as any WindowMaking).makeWindow(frame: frame)
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.frame = frame
        host.view.layoutIfNeeded()
        for _ in 0..<attempts {
            let image = try picture(of: window)
            if try isReady(image) { return image }
            try await Task.sleep(for: interval)
        }
        throw RenderingError.neverReady
    }

    /// Returns the picture of what a window shows now.
    ///
    /// - Parameter window: The window to read.
    /// - Returns: The window's picture, at the render's scale.
    /// - Throws: When the picture cannot be made.
    private func picture(of window: UIWindow) throws -> CGImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = CGFloat(scale)
        let image = UIGraphicsImageRenderer(size: window.bounds.size, format: format).image { context in
            window.layer.render(in: context.cgContext)
        }
        return try #require(image.cgImage)
    }
}
#endif
