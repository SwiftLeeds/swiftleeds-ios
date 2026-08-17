import Foundation
import LogKit
import Testing

@Suite struct LogDescribableTests {
    @Test func whenErrorDescribesItself_shouldUseThatDescription() {
        #expect(String(logDescribing: Conforming.boom) == "CUSTOM")
    }

    @Test func whenErrorDoesNotDescribeItself_shouldFallBackToItsDefault() {
        #expect(String(logDescribing: Plain.boom) == "boom")
    }

    @Test func whenFieldIsBuiltFromError_shouldUseItsLogDescription() {
        #expect(LogField.open("reason", Conforming.boom) == .open("reason", "CUSTOM"))
    }

    @Test func whenFieldIsBuiltFromError_shouldKeepTheStatedSensitivity() {
        #expect(LogField.secret("reason", Conforming.boom).sensitivity == .secret)
        #expect(LogField.hashed("reason", Conforming.boom).sensitivity == .hashed)
    }

    @Test func whenKeyIsMissing_shouldNameThePathAndKey() throws {
        struct Ticket: Decodable { let lastName: String }
        struct Payload: Decodable { let ticket: Ticket }

        let error = try #require(caught(decoding: #"{"ticket": {}}"#, as: Payload.self))

        #expect(String(logDescribing: error) == "keyNotFound ticket.lastName")
    }

    @Test func whenTypeIsWrong_shouldNameTheExpectedType() throws {
        struct Payload: Decodable { let count: Int }

        let error = try #require(caught(decoding: #"{"count": "many"}"#, as: Payload.self))

        #expect(String(logDescribing: error) == "typeMismatch count expected Int")
    }

    @Test func whenBodyIsNotJSON_shouldSayDataCorrupted() throws {
        struct Payload: Decodable { let count: Int }

        let error = try #require(caught(decoding: "not json", as: Payload.self))

        #expect(String(logDescribing: error) == "dataCorrupted")
    }
}

private enum Conforming: Error, LogDescribable {
    case boom
    var logDescription: String { "CUSTOM" }
}

private enum Plain: Error {
    case boom
}

private func caught<T: Decodable>(decoding json: String, as type: T.Type) -> (any Error)? {
    do {
        _ = try JSONDecoder().decode(type, from: Data(json.utf8))
        return nil
    } catch {
        return error
    }
}
