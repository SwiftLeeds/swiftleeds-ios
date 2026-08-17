import Foundation
import LogKit
import Testing

@Suite struct LogSaltTests {
    @Test func whenGeneratedRandomly_shouldDifferBetweenSalts() {
        #expect(LogSalt.random() != LogSalt.random())
    }

    @Test func whenGeneratedWithByteCount_shouldProduceThatManyBytes() {
        #expect(Data(LogSalt.random(byteCount: 32)).count == 32)
    }

    @Test func whenBuiltFromData_shouldReturnSameData() {
        let bytes = Data("fixed-for-tests".utf8)

        #expect(Data(LogSalt(bytes)) == bytes)
    }
}
