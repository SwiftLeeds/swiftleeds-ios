import LogKit
import Testing

@Suite struct LogValueTests {
    @Test func whenWrittenAsStringLiteral_shouldBeString() {
        let sut: LogValue = "ada"

        #expect(sut == .string("ada"))
    }

    @Test func whenWrittenAsIntegerLiteral_shouldBeInteger() {
        let sut: LogValue = 42

        #expect(sut == .integer(42))
    }

    @Test func whenWrittenAsFloatLiteral_shouldBeDouble() {
        let sut: LogValue = 1.5

        #expect(sut == .double(1.5))
    }

    @Test func whenWrittenAsBooleanLiteral_shouldBeBoolean() {
        let sut: LogValue = true

        #expect(sut == .boolean(true))
    }

    @Test func whenNumberIsStored_shouldStayNumberRatherThanText() {
        let sut: LogValue = 200

        #expect(sut != .string("200"))
    }

    @Test func whenNested_shouldPreserveStructure() {
        let sut = LogValue.dictionary(["status": 200, "tags": .array(["a", "b"])])

        #expect(sut == .dictionary(["status": .integer(200), "tags": .array([.string("a"), .string("b")])]))
    }
}
