import AuthenticationUI
import Dependencies
import Testing

@MainActor
@Suite struct TicketViewModelTests {
    @Test func whenDisplayingBegins_shouldBrightenScreenAndKeepItAwake() {
        let display = DisplaySpy(brightness: 0.4)

        withDependencies(display.install) {
            let sut = TicketView.ViewModel()

            sut.beginDisplaying()

            #expect(display.brightness == .brightest)
            #expect(display.autoLockEnabled == false)
        }
    }

    @Test func whenDisplayingEnds_shouldRestoreBrightnessAndLocking() {
        let display = DisplaySpy(brightness: 0.4)

        withDependencies(display.install) {
            let sut = TicketView.ViewModel()
            sut.beginDisplaying()

            sut.endDisplaying()

            #expect(display.brightness == 0.4)
            #expect(display.autoLockEnabled == true)
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
            #expect(display.autoLockEnabled == true)
        }
    }
}

@MainActor
private final class DisplaySpy {
    var brightness: ScreenBrightness.Level
    var autoLockEnabled = true

    init(brightness: ScreenBrightness.Level) {
        self.brightness = brightness
    }

    func install(_ values: inout DependencyValues) {
        values.screenBrightness = ScreenBrightness(
            current: { self.brightness },
            set: { self.brightness = $0 }
        )
        values.screenAutoLock = ScreenAutoLock(
            enable: { self.autoLockEnabled = true },
            disable: { self.autoLockEnabled = false }
        )
    }
}
