import AuthenticationUI
import Dependencies
import Testing

@MainActor
@Suite struct TicketViewModelTests {
    /// A spy that stands in for the screen's brightness and auto-lock.
    @MainActor
    private final class DisplaySpy {
        /// The screen's current brightness.
        var brightness: ScreenBrightness.Level

        /// Whether the screen may lock itself.
        var autoLockEnabled = true

        /// Creates a spy with the screen at a given brightness.
        ///
        /// - Parameter brightness: The brightness the screen starts at.
        init(brightness: ScreenBrightness.Level) {
            self.brightness = brightness
        }

        /// Replaces the screen brightness and auto-lock dependencies with this spy.
        ///
        /// - Parameter values: The dependency values to change.
        func install(_ values: inout DependencyValues) {
            values.screenBrightness = ScreenBrightness(
                current: { self.brightness },
                set: { self.brightness = $0 },
            )
            values.screenAutoLock = ScreenAutoLock(
                enable: { self.autoLockEnabled = true },
                disable: { self.autoLockEnabled = false },
            )
        }
    }

    @Test func whenDisplayingBegins_shouldBrightenScreenAndKeepItAwake() {
        let display = DisplaySpy(brightness: 0.4)

        withDependencies(display.install) {
            let sut = TicketView.ViewModel()

            sut.beginDisplaying()

            #expect(display.brightness == .brightest)
            #expect(!display.autoLockEnabled)
        }
    }

    @Test func whenDisplayingEnds_shouldRestoreBrightnessAndLocking() {
        let display = DisplaySpy(brightness: 0.4)

        withDependencies(display.install) {
            let sut = TicketView.ViewModel()
            sut.beginDisplaying()

            sut.endDisplaying()

            #expect(display.brightness == 0.4)
            #expect(display.autoLockEnabled)
        }
    }

    @Test func whenDisplayingBeginsTwice_shouldStillRestoreTheOriginalBrightness() {
        let display = DisplaySpy(brightness: 0.4)

        withDependencies(display.install) {
            let sut = TicketView.ViewModel()
            sut.beginDisplaying()

            sut.beginDisplaying()
            sut.endDisplaying()

            #expect(display.brightness == 0.4)
        }
    }

    @Test func whenBackgroundedAndForegrounded_shouldRestoreTheOriginalBrightness() {
        let display = DisplaySpy(brightness: 0.4)

        withDependencies(display.install) {
            let sut = TicketView.ViewModel()
            sut.beginDisplaying()

            sut.endDisplaying()
            sut.beginDisplaying()
            sut.endDisplaying()

            #expect(display.brightness == 0.4)
        }
    }

    @Test func whenDisplayingEndsWithoutBeginning_shouldLeaveTheScreenAlone() {
        let display = DisplaySpy(brightness: 0.4)

        withDependencies(display.install) {
            let sut = TicketView.ViewModel()

            sut.endDisplaying()

            #expect(display.brightness == 0.4)
            #expect(display.autoLockEnabled)
        }
    }
}
