import Dependencies
import Foundation
import SponsorsFeature
import Testing

@Suite struct SponsorMapperTests {
    private let sut = SponsorMapper.live

    @Test func whenResponseIsWellFormed_shouldDecodeAndRead() throws {
        let data = SponsorsJSON.list(
            SponsorsJSON.sponsor(id: "a", level: "platinum"),
            SponsorsJSON.sponsor(id: "b", level: "gold")
        )

        let sponsors = try sut.map(data, try .fixture(statusCode: 200))

        #expect(sponsors.map(\.id) == [SponsorID("a"), SponsorID("b")])
    }

    @Test func whenBodyIsNotTheExpectedShape_shouldThrowCouldNotDecode() throws {
        let response = try HTTPURLResponse.fixture(statusCode: 200)

        #expect(throws: SponsorMapper.ResponseError.self) {
            try sut.map(Data("{\"unexpected\":true}".utf8), response)
        }
    }

    @Test(arguments: [404, 500])
    func whenStatusIsNotOK_shouldThrowUnexpectedStatus(statusCode: Int) throws {
        let data = SponsorsJSON.list(SponsorsJSON.sponsor())
        let response = try HTTPURLResponse.fixture(statusCode: statusCode)

        #expect(throws: SponsorMapper.ResponseError.self) {
            try sut.map(data, response)
        }
    }

    // A refusal from translation reaches the caller.
    @Test func whenReaderRefuses_shouldThrowUnknownLevel() throws {
        let data = SponsorsJSON.list(SponsorsJSON.sponsor(level: "bronze"))
        let response = try HTTPURLResponse.fixture(statusCode: 200)

        #expect(throws: SponsorMapper.ResponseError.self) {
            try sut.map(data, response)
        }
    }

    // Translating is the reader's job. Removing that call fails this and
    // nothing else.
    @Test func whenDecoded_shouldReturnWhateverTheReaderMakes() throws {
        let data = SponsorsJSON.list(SponsorsJSON.sponsor(id: "ignored"))
        let response = try HTTPURLResponse.fixture(statusCode: 200)

        let sponsors = try withDependencies {
            $0.sponsorsReader = SponsorsReader { _ in [.fixture(id: SponsorID("from-the-reader"))] }
        } operation: {
            try sut.map(data, response)
        }

        #expect(sponsors.map(\.id) == [SponsorID("from-the-reader")])
    }
}
