import LogKit
import Testing

@Suite struct LogFieldsTests {
    @Test func whenBuiltFromArrayLiteral_shouldKeepWrittenOrder() {
        let sut: LogFields = [.open("first", 1), .open("second", 2), .open("third", 3)]

        #expect(sut.map(\.name) == ["first", "second", "third"])
    }

    @Test func whenSameFieldsInDifferentOrder_shouldNotBeEqual() {
        let first = LogField.open("a", 1)
        let second = LogField.hashed("b", "x")

        #expect(LogFields([first, second]) != LogFields([second, first]))
    }

    @Test func whenAppendingField_shouldPlaceItLast() {
        let sut = LogFields([.open("first", 1)]).appending(.open("second", 2))

        #expect(sut.map(\.name) == ["first", "second"])
    }

    @Test func whenAppendingFields_shouldKeepBothSequencesInOrder() {
        let sut = LogFields([.open("a", 1)]).appending(contentsOf: LogFields([.open("b", 2), .open("c", 3)]))

        #expect(sut.map(\.name) == ["a", "b", "c"])
    }

    @Test func whenAppending_shouldLeaveOriginalUnchanged() {
        let sut = LogFields([.open("only", 1)])

        _ = sut.appending(.open("extra", 2))

        #expect(sut.map(\.name) == ["only"])
    }

    @Test func whenBuiltWithNoFields_shouldBeEmpty() {
        #expect(LogFields().isEmpty)
    }
}
