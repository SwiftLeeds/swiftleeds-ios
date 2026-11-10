#if os(iOS)
import UIKit

/// A maker of a window for a hosted view.
@MainActor
protocol WindowMaking {
    /// Returns a window that fills a frame.
    ///
    /// - Parameter frame: The frame of the window.
    /// - Returns: The window.
    func makeWindow(frame: CGRect) -> UIWindow
}
#endif
