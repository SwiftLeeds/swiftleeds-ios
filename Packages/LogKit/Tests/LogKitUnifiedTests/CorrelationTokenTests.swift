import Foundation
import LogKit
import Testing

@testable import LogKitUnified

@Suite struct CorrelationTokenTests {
    private let salt = LogSalt(Data("fixed-for-tests".utf8))

    @Test func whenSameValueAndSalt_shouldProduceSameToken() {
        let first = String(CorrelationToken("ada@example.com", salt: salt))
        let second = String(CorrelationToken("ada@example.com", salt: salt))

        #expect(first == second)
    }

    @Test func whenDifferentValues_shouldProduceDifferentTokens() {
        let ada = String(CorrelationToken("ada@example.com", salt: salt))
        let grace = String(CorrelationToken("grace@example.com", salt: salt))

        #expect(ada != grace)
    }

    @Test func whenSaltDiffers_shouldProduceDifferentTokenForSameValue() {
        let mine = String(CorrelationToken("ada@example.com", salt: salt))
        let theirs = String(CorrelationToken("ada@example.com", salt: LogSalt(Data("other".utf8))))

        #expect(mine != theirs)
    }

    @Test func whenTokenised_shouldNotContainTheOriginalValue() {
        let sut = String(CorrelationToken("ada@example.com", salt: salt))

        #expect(!sut.contains("ada"))
        #expect(!sut.contains("@"))
    }

    @Test func whenTokenised_shouldBeSixteenHexadecimalCharacters() {
        let sut = String(CorrelationToken("ada@example.com", salt: salt))
        let isHexadecimal = sut.allSatisfy(\.isHexDigit)

        #expect(sut.count == 16)
        #expect(isHexadecimal)
    }

    @Test func whenAnyByteIsBelowSixteen_shouldStillProduceTwoCharactersPerByte() {
        // Zero padding means every token is the same length whatever the bytes.
        let lengths = (0..<64).map { index in
            String(CorrelationToken("value-\(index)", salt: salt)).count
        }

        #expect(Set(lengths) == [16])
    }

    @Test func whenGeneratedRandomly_shouldDifferBetweenSalts() {
        #expect(LogSalt.random() != LogSalt.random())
    }
}
