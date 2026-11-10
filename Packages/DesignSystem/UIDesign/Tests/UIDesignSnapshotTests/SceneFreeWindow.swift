#if os(iOS)
import UIKit

/// A maker of a window with no window scene, because the test bundle has none.
@MainActor
struct SceneFreeWindow: WindowMaking {
    /// Returns a window with no window scene that fills a frame.
    ///
    /// - Parameter frame: The frame of the window.
    /// - Returns: The window.
    @available(iOS, deprecated: 26.0, message: "Only for a test bundle with no window scene")
    func makeWindow(frame: CGRect) -> UIWindow {
        UIWindow(frame: frame)
    }
}
#endif
