import Dependencies

/// The display's brightness.
package struct ScreenBrightness: Sendable {
    /// How bright the display is, from dimmest to brightest.
    package struct Level: ExpressibleByFloatLiteral, Equatable, Sendable {
        /// The fraction of full brightness, from 0 to 1.
        fileprivate let storage: Double

        /// Creates a level, pinning `value` to the range the display accepts.
        ///
        /// A value that is not a number is treated as the dimmest setting.
        /// - Parameter value: The fraction of full brightness.
        package init(_ value: Double) {
            storage = value.isNaN ? 0 : min(max(value, 0), 1)
        }

        package init(floatLiteral value: Double) {
            self.init(value)
        }

        /// The brightest the display goes.
        package static let brightest = Level(1)
    }

    /// Reads the current level.
    package var current: @MainActor @Sendable () -> Level
    /// Sets the level.
    package var set: @MainActor @Sendable (Level) -> Void

    /// Creates a brightness control.
    package init(
        current: @escaping @MainActor @Sendable () -> Level,
        set: @escaping @MainActor @Sendable (Level) -> Void,
    ) {
        self.current = current
        self.set = set
    }
}

extension Double {
    /// Creates a number from a brightness level, for handing to the system.
    /// - Parameter level: The level to convert.
    package init(_ level: ScreenBrightness.Level) {
        self = level.storage
    }
}

extension ScreenBrightness: DependencyKey {
    package static var liveValue: ScreenBrightness {
        #if os(iOS)
        ScreenBrightness(
            current: { Level(Double(activeScreen()?.brightness ?? 0)) },
            set: { activeScreen()?.brightness = Double($0) },
        )
        #else
        ScreenBrightness(current: { .brightest }, set: { _ in })
        #endif
    }

    package static var testValue: ScreenBrightness {
        ScreenBrightness(
            current: {
                reportIssue("ScreenBrightness.current is unimplemented")
                return .brightest
            },
            set: { _ in
                reportIssue("ScreenBrightness.set is unimplemented")
            },
        )
    }
}

extension DependencyValues {
    /// The control for the display's brightness.
    package var screenBrightness: ScreenBrightness {
        get { self[ScreenBrightness.self] }
        set { self[ScreenBrightness.self] = newValue }
    }
}

#if os(iOS)
import UIKit

/// Returns the screen of the foreground scene, if any.
@MainActor
private func activeScreen() -> UIScreen? {
    // UIScreen.main is deprecated; the replacement is to find the screen
    // through the active scene.
    UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .first { $0.activationState == .foregroundActive }?
        .screen
}
#endif
