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

    /// A step in seconds that is small enough to stay inside one text.
    private static let tinyStep: TimeInterval = 0.001

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

    @Test
    func whenTwelveMinutesTenSecondsRemain_shouldReturnFirstMomentOfNextText() throws {
        let sut = Self.britishEnglishInGMT
        let now = Self.start.addingTimeInterval(-(12 * 60 + 10))
        let moment = try #require(sut.discreteInput(after: now))
        #expect(sut.format(moment) != sut.format(now))
        #expect(sut.format(moment.addingTimeInterval(-Self.tinyStep)) == sut.format(now))
    }

    @Test
    func whenTwelveMinutesRemain_shouldReturnLastMomentOfPreviousText() throws {
        let sut = Self.britishEnglishInGMT
        let now = Self.start.addingTimeInterval(-12 * 60)
        let moment = try #require(sut.discreteInput(before: now))
        #expect(sut.format(moment) != sut.format(now))
        #expect(sut.format(moment.addingTimeInterval(Self.tinyStep)) == sut.format(now))
    }

    @Test
    func whenSixtyOneSecondsRemain_shouldReturnStartOfNowStretch() {
        let sut = Self.britishEnglishInGMT
        let now = Self.start.addingTimeInterval(-61)
        #expect(sut.discreteInput(after: now) == Self.start.addingTimeInterval(-60))
    }

    @Test
    func whenEightySecondsRemain_shouldReturnStartOfNowStretch() {
        let sut = Self.britishEnglishInGMT
        let now = Self.start.addingTimeInterval(-80)
        #expect(sut.discreteInput(after: now) == Self.start.addingTimeInterval(-60))
    }

    @Test(arguments: [-60.0, -30.0, 5 * 60.0])
    func whenReadingNow_shouldReturnNoNextChange(secondsFromStart: TimeInterval) {
        let sut = Self.britishEnglishInGMT
        let now = Self.start.addingTimeInterval(secondsFromStart)
        #expect(sut.discreteInput(after: now) == nil)
    }

    @Test(arguments: [-60.0, -30.0, 5 * 60.0])
    func whenReadingNow_shouldReturnLastMomentOfPreviousText(secondsFromStart: TimeInterval) throws {
        let sut = Self.britishEnglishInGMT
        let now = Self.start.addingTimeInterval(secondsFromStart)
        let moment = try #require(sut.discreteInput(before: now))
        #expect(moment < now)
        #expect(sut.format(moment) != sut.format(now))
        #expect(sut.format(moment.addingTimeInterval(Self.tinyStep)) == sut.format(now))
    }

    @Test
    func whenWalkingBackFromNow_shouldReturnEarlierMomentEachStep() throws {
        let sut = Self.britishEnglishInGMT
        var moment = Self.start.addingTimeInterval(-60)
        for _ in 0..<5 {
            let earlier = try #require(sut.discreteInput(before: moment))
            #expect(earlier < moment)
            moment = earlier
        }
    }

    @Test
    func whenMadeWithStaticMember_shouldFormatLikeInitializer() {
        let now = Self.start.addingTimeInterval(-12 * 60)
        let expected = CountdownFormatStyle(to: Self.start).format(now)
        #expect(now.formatted(.countdown(to: Self.start)) == expected)
    }

    @Test
    func whenEncodedAndDecoded_shouldReturnEqualStyle() throws {
        let sut = Self.britishEnglishInGMT
        let data = try JSONEncoder().encode(sut)
        #expect(try JSONDecoder().decode(CountdownFormatStyle.self, from: data) == sut)
    }

    @Test
    func whenEncodedStartIsEdited_shouldCountToTheEditedStartEverywhere() throws {
        let editedStart = Self.start.addingTimeInterval(600)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let json = try #require(String(data: encoder.encode(Self.britishEnglishInGMT), encoding: .utf8))
        let startText = "800000000"
        let occurrences = json.ranges(of: startText)
        #expect(!occurrences.isEmpty)
        for occurrence in occurrences {
            var edited = json
            edited.replaceSubrange(occurrence, with: "800000600")
            let sut = try JSONDecoder().decode(CountdownFormatStyle.self, from: Data(edited.utf8))
            #expect(sut.format(editedStart.addingTimeInterval(-12 * 60)) == "in 12 min")
            #expect(sut.format(editedStart.addingTimeInterval(-30)) == "now")
            #expect(sut.format(editedStart.addingTimeInterval(5 * 60)) == "now")
        }
    }
}
