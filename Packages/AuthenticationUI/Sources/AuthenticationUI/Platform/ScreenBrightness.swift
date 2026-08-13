import Dependencies

/// The display's brightness.
package struct ScreenBrightness: Sendable {
    /// How bright the display is, from dimmest to brightest.
    package struct Level: ExpressibleByFloatLiteral, Equatable, Sendable {
        private let storage: Double

        /// Creates a level, pinning `value` to the range the display accepts.
        package init(_ value: Double) {
            storage = min(max(value, 0), 1)
        }

        package init(floatLiteral value: Double) {
            self.init(value)
        }

        /// The brightest the display goes.
        package static let brightest = Level(1)

        fileprivate var doubleValue: Double { storage }
    }

    /// Reads the current level.
    package var current: @MainActor @Sendable () -> Level
    /// Sets the level.
    package var set: @MainActor @Sendable (Level) -> Void

    package init(
        current: @escaping @MainActor @Sendable () -> Level,
        set: @escaping @MainActor @Sendable (Level) -> Void
    ) {
        self.current = current
        self.set = set
    }
}

extension Double {
    /// Creates a number from a brightness level, for handing to the system.
    package init(_ level: ScreenBrightness.Level) {
        self = level.doubleValue
    }
}

extension ScreenBrightness: DependencyKey {
    package static var liveValue: ScreenBrightness {
        #if os(iOS)
        ScreenBrightness(
            current: { Level(Double(activeScreen()?.brightness ?? 0)) },
            set: { activeScreen()?.brightness = Double($0) }
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
            }
        )
    }
}

extension DependencyValues {
    package var screenBrightness: ScreenBrightness {
        get { self[ScreenBrightness.self] }
        set { self[ScreenBrightness.self] = newValue }
    }
}

#if os(iOS)
import UIKit

// UIScreen.main is deprecated; the replacement is to find the screen through the active scene.
@MainActor
private func activeScreen() -> UIScreen? {
    UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .first { $0.activationState == .foregroundActive }?
        .screen
}
#endif
