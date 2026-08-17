import LogKit
import Testing

@Suite struct LogMessageTests {
    @Test func whenWrittenAsLiteral_shouldHaveNoGapsOrValues() {
        let sut: LogMessage = "Registering for push"

        #expect(sut.template.leadingText == "Registering for push")
        #expect(sut.template.gaps.isEmpty)
        #expect(sut.values.isEmpty)
    }

    @Test func whenInterpolated_shouldSplitLiteralAroundTheGap() {
        let sut: LogMessage = "Signed in as \("ada", privacy: .open) today"

        #expect(sut.template.leadingText == "Signed in as ")
        #expect(sut.template.gaps.map(\.trailingText) == [" today"])
    }

    @Test func whenInterpolated_shouldMakeTheValueAField() {
        let sut: LogMessage = "Signed in as \("ada", privacy: .open)"

        #expect(sut.values.map(\.value) == [.string("ada")])
        #expect(sut.values.map(\.sensitivity) == [.open])
    }

    @Test func whenInterpolatedWithoutName_shouldNameTheFieldByPosition() {
        let sut: LogMessage = "\(1, privacy: .open) then \(2, privacy: .open)"

        #expect(sut.values.map(\.name) == [.positional(GapIndex(0), label: nil),
                                           .positional(GapIndex(1), label: nil)])
    }

    @Test func whenInterpolatedWithName_shouldLabelTheField() {
        let sut: LogMessage = "Rejected \(401, name: "statusCode", privacy: .open)"

        #expect(sut.values.map(\.name) == [.positional(GapIndex(0), label: "statusCode")])
    }

    @Test func whenTwoInterpolationsShareName_shouldStayDistinct() {
        let sut: LogMessage = "\("a", name: "user", privacy: .open) and \("b", name: "user", privacy: .secret)"

        #expect(sut.values.map(\.name) == [.positional(GapIndex(0), label: "user"),
                                           .positional(GapIndex(1), label: "user")])
        #expect(sut.values.map(\.sensitivity) == [.open, .secret])
    }

    @Test func whenInterpolationsAreAdjacent_shouldKeepEmptyTextBetween() {
        let sut: LogMessage = "\(1, privacy: .open)\(2, privacy: .open)"

        #expect(sut.template.leadingText.isEmpty)
        #expect(sut.template.gaps.map(\.trailingText) == ["", ""])
    }

    @Test func whenMessageEndsWithLiteral_shouldTrailTheLastGap() {
        let sut: LogMessage = "Token \("abc", privacy: .secret) rejected"

        #expect(sut.template.gaps.map(\.trailingText) == [" rejected"])
    }

    @Test func whenSensitivitiesDiffer_shouldCarryEachOne() {
        let sut: LogMessage = "\(1, privacy: .open) \(2, privacy: .hashed) \(3, privacy: .secret)"

        #expect(sut.values.map(\.sensitivity) == [.open, .hashed, .secret])
    }
}
