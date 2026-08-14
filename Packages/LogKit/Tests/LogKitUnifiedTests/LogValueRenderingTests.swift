import Foundation
import LogKit
import Testing

@testable import LogKitUnified

@Suite struct LogValueRenderingTests {
    private let salt = LogSalt(Data("fixed-for-tests".utf8))

    @Test func whenRenderingScalars_shouldUseTheirTextForm() {
        #expect(LogValue.string("ada").rendered == "ada")
        #expect(LogValue.integer(200).rendered == "200")
        #expect(LogValue.boolean(true).rendered == "true")
    }

    @Test func whenRenderingArray_shouldKeepElementOrder() {
        #expect(LogValue.array(["a", "b", "c"]).rendered == "[a, b, c]")
    }

    @Test func whenRenderingDictionary_shouldSortKeysForStableOutput() {
        let sut = LogValue.dictionary(["status": 200, "again": false])

        #expect(sut.rendered == "[again: false, status: 200]")
    }

    @Test func whenRenderingFields_shouldKeepWrittenOrderAcrossSensitivities() {
        let sut: LogFields = [.open("second", 2), .hashed("first", "x"), .open("third", 3)]

        let rendered = sut.rendered(salt: salt)

        #expect(rendered.hasPrefix("second=2 first="))
        #expect(rendered.hasSuffix(" third=3"))
    }

    @Test func whenFieldIsHashed_shouldRenderTokenRatherThanValue() {
        let sut: LogFields = [.hashed("email", "ada@example.com")]

        #expect(!sut.rendered(salt: salt).contains("ada@example.com"))
        #expect(sut.rendered(salt: salt).hasPrefix("email="))
    }

    @Test func whenNeighbouringFieldChanges_shouldKeepSameTokenForUnchangedField() {
        let first: LogFields = [.hashed("email", "ada@example.com"), .open("reference", "ABCD-1")]
        let second: LogFields = [.hashed("email", "ada@example.com"), .open("reference", "WXYZ-9")]

        let firstToken = first.rendered(salt: salt).split(separator: " ")[0]
        let secondToken = second.rendered(salt: salt).split(separator: " ")[0]

        #expect(firstToken == secondToken)
    }

    @Test func whenTwoFieldsAreHashed_shouldTokeniseEachSeparately() {
        let sut: LogFields = [.hashed("email", "ada@example.com"), .hashed("reference", "ABCD-1")]

        let parts = sut.rendered(salt: salt).split(separator: " ")

        #expect(parts.count == 2)
        #expect(parts[0] != parts[1])
    }

    @Test func whenFieldIsSecret_shouldBeExcludedFromTheRenderedFields() {
        let sut: LogFields = [.open("scheme", "ticket"), .secret("token", "abc")]

        #expect(sut.rendered(salt: salt) == "scheme=ticket")
    }

    @Test func whenRenderingSecrets_shouldIncludeOnlySecretFields() {
        let sut: LogFields = [.open("scheme", "ticket"), .secret("token", "abc")]

        #expect(sut.renderedSecrets == "token=abc")
    }

    @Test func whenRenderingNoFields_shouldProduceEmptyText() {
        #expect(LogFields().rendered(salt: salt).isEmpty)
    }
}
