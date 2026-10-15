import Foundation
import LogKit
import Testing

@Suite struct LogSaltTests {
    @Test func whenGeneratedRandomly_shouldDifferBetweenSalts() {
        #expect(LogSalt.random() != LogSalt.random())
    }

    @Test func whenGeneratedRandomly_shouldProduceSixteenBytes() {
        #expect(Data(LogSalt.random()).count == 16)
    }

    @Test func whenBuiltFromData_shouldReturnSameData() {
        let bytes = Data("fixed-for-tests".utf8)

        #expect(Data(LogSalt(bytes)) == bytes)
    }
}
