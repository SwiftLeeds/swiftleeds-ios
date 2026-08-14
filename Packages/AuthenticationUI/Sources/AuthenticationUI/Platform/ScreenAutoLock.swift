import Dependencies

/// Whether the screen may dim and lock on its own, as set in Settings under Auto-Lock.
package struct ScreenAutoLock: Sendable {
    /// Lets the screen lock on its own again.
    package var enable: @MainActor @Sendable () -> Void
    /// Stops the screen locking on its own.
    package var disable: @MainActor @Sendable () -> Void

    package init(
        enable: @escaping @MainActor @Sendable () -> Void,
        disable: @escaping @MainActor @Sendable () -> Void
    ) {
        self.enable = enable
        self.disable = disable
    }
}

extension ScreenAutoLock: DependencyKey {
    package static var liveValue: ScreenAutoLock {
        #if os(iOS)
        ScreenAutoLock(
            enable: { UIApplication.shared.isIdleTimerDisabled = false },
            disable: { UIApplication.shared.isIdleTimerDisabled = true }
        )
        #else
        ScreenAutoLock(enable: {}, disable: {})
        #endif
    }

    package static var testValue: ScreenAutoLock {
        ScreenAutoLock(
            enable: { reportIssue("ScreenAutoLock.enable is unimplemented") },
            disable: { reportIssue("ScreenAutoLock.disable is unimplemented") }
        )
    }
}

extension DependencyValues {
    package var screenAutoLock: ScreenAutoLock {
        get { self[ScreenAutoLock.self] }
        set { self[ScreenAutoLock.self] = newValue }
    }
}

#if os(iOS)
import UIKit
#endif
