import Dependencies
import Observation

extension TicketView {
    @MainActor
    @Observable
    package final class ViewModel {
        @ObservationIgnored
        @Dependency(\.screenBrightness) private var screenBrightness
        @ObservationIgnored
        @Dependency(\.screenAutoLock) private var screenAutoLock

        private var brightnessToRestore: ScreenBrightness.Level?

        package init() {}

        /// Brightens the screen and stops it locking, so the code can be scanned.
        package func beginDisplaying() {
            guard brightnessToRestore == nil else { return }
            brightnessToRestore = screenBrightness.current()
            screenBrightness.set(.brightest)
            screenAutoLock.disable()
        }

        /// Puts the brightness and locking back how they were.
        package func endDisplaying() {
            guard let brightnessToRestore else { return }
            screenBrightness.set(brightnessToRestore)
            screenAutoLock.enable()
            self.brightnessToRestore = nil
        }
    }
}
