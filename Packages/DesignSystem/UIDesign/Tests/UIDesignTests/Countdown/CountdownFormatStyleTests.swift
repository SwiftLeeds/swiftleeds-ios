import Foundation
import Testing
import UIDesign

@Suite
struct CountdownFormatStyleTests {
    /// The moment every test counts towards.
    private static let start = Date(timeIntervalSinceReferenceDate: 800_000_000)

    /// British English, the language the snapshot scheme pins.
    private static let britishEnglish = Locale(identifier: "en_GB")

    /// A Gregorian calendar in GMT, so no machine's time zone moves a boundary.
    private static var gregorianInGMT: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .gmt
        return calendar
    }

    /// A countdown to the start in British English and a Gregorian calendar in GMT.
    private static var britishEnglishInGMT: CountdownFormatStyle {
        CountdownFormatStyle(to: start)
            .locale(britishEnglish)
            .calendar(gregorianInGMT)
    }

    /// 09:00 GMT on 29 March 2026, the day UK clocks go forward.
    private static var clockChangeStart: Date {
        get throws {
            try #require(ISO8601DateFormatter().date(from: "2026-03-29T09:00:00Z"))
        }
    }

    @Test
    func whenTwelveMinutesRemain_shouldReturnInTwelveMin() {
        let sut = CountdownFormatStyle(to: Self.start)
            .locale(Self.britishEnglish)
            .calendar(Self.gregorianInGMT)
        let now = Self.start.addingTimeInterval(-12 * 60)
        #expect(sut.format(now) == "in 12 min")
    }

    @Test
    func whenTwelveDaysRemain_shouldReturnInTwelveDays() {
        let sut = Self.britishEnglishInGMT
        let now = Self.start.addingTimeInterval(-12 * 24 * 60 * 60)
        #expect(sut.format(now) == "in 12 days")
    }

    @Test
    func whenOneHourFiftyNineRemain_shouldReturnInTwoHr() {
        let sut = Self.britishEnglishInGMT
        let now = Self.start.addingTimeInterval(-(60 + 59) * 60)
        #expect(sut.format(now) == "in 2 hr")
    }

    @Test
    func whenLocaleIsGerman_shouldReturnInTwelveMinInGerman() {
        let sut = Self.britishEnglishInGMT.locale(Locale(identifier: "de_DE"))
        let now = Self.start.addingTimeInterval(-12 * 60)
        #expect(sut.format(now) == "in 12 Min.")
    }

    @Test
    func whenCalendarIsInLondonAcrossClockChange_shouldReturnInOneDay() throws {
        var london = Calendar(identifier: .gregorian)
        london.timeZone = try #require(TimeZone(identifier: "Europe/London"))
        let sut = CountdownFormatStyle(to: try Self.clockChangeStart)
            .locale(Self.britishEnglish)
            .calendar(london)
        let now = try Self.clockChangeStart.addingTimeInterval(-23 * 60 * 60)
        #expect(sut.format(now) == "in 1 day")
    }

    @Test
    func whenCalendarIsInGMTAcrossClockChange_shouldReturnInTwentyThreeHr() throws {
        let sut = CountdownFormatStyle(to: try Self.clockChangeStart)
            .locale(Self.britishEnglish)
            .calendar(Self.gregorianInGMT)
        let now = try Self.clockChangeStart.addingTimeInterval(-23 * 60 * 60)
        #expect(sut.format(now) == "in 23 hr")
    }

    @Test
    func whenSixtySecondsRemain_shouldReturnNow() {
        let sut = Self.britishEnglishInGMT
        let now = Self.start.addingTimeInterval(-60)
        #expect(sut.format(now) == "now")
    }

    @Test
    func whenSixtyOneSecondsRemain_shouldReturnInOneMin() {
        let sut = Self.britishEnglishInGMT
        let now = Self.start.addingTimeInterval(-61)
        #expect(sut.format(now) == "in 1 min")
    }

    @Test
    func whenThirtySecondsRemain_shouldReturnNow() {
        let sut = Self.britishEnglishInGMT
        let now = Self.start.addingTimeInterval(-30)
        #expect(sut.format(now) == "now")
    }

    @Test
    func whenStartHasPassed_shouldReturnNow() {
        let sut = Self.britishEnglishInGMT
        let now = Self.start.addingTimeInterval(5 * 60)
        #expect(sut.format(now) == "now")
    }

    @Test
    func whenLocaleIsGerman_shouldReturnJetzt() {
        let sut = Self.britishEnglishInGMT.locale(Locale(identifier: "de_DE"))
        let now = Self.start.addingTimeInterval(-30)
        #expect(sut.format(now) == "jetzt")
    }
}
