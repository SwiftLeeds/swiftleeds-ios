import Foundation
import LogKit
import Testing

/// These assert what a destination is *unable* to see. The recorder here writes down whatever it is
/// handed, so anything it observes is something a real destination could have leaked.
///
/// Events are written directly rather than through a level method, so these cover classification
/// alone. The path from a call site is covered by `InterpolatedEventTests`.
@Suite struct LogDestinationTests {
    private let salt = LogSalt(Data("fixed-for-tests".utf8))

    private func event(_ fields: LogField...) -> LogEvent {
        LogEvent(level: .error, category: "push", message: "m", fields: LogFields(fields))
    }

    // MARK: - Secrets

    @Test func whenBuiltWithDefaults_shouldNotReceiveSecretFields() {
        let recorder = LogRecorder()
        let sut = Log.destination(salt: salt, write: recorder.log.write)

        sut.write(event(.open("scheme", "ticket"), .secret("token", "abc123")))

        #expect(recorder.events.first?.fields.map { String($0.name) } == ["scheme"])
    }

    @Test func whenBuiltWithDefaults_shouldNotReceiveASecretValueAnywhere() {
        let recorder = LogRecorder()
        let sut = Log.destination(salt: salt, write: recorder.log.write)

        sut.write(event(.secret("token", "abc123")))

        let values = recorder.events.flatMap { $0.fields.map(\.value.rendered) }
        #expect(!values.contains("abc123"))
    }

    @Test func whenPassingSecretsThrough_shouldReceiveThemUnchanged() {
        let recorder = LogRecorder()
        let sut = Log.destination(salt: salt, secrets: .passThrough, write: recorder.log.write)

        sut.write(event(.secret("token", "abc123")))

        #expect(recorder.events.first?.fields.map(\.value) == [.string("abc123")])
    }

    // MARK: - Hashed values

    @Test func whenFieldIsHashed_shouldReceiveNoFragmentOfTheValue() {
        let recorder = LogRecorder()
        let sut = Log.destination(salt: salt, write: recorder.log.write)

        sut.write(event(.hashed("email", "ada@example.com")))

        let value = recorder.events.first?.fields.map(\.value).first?.rendered
        #expect(value?.contains("ada") == false)
        #expect(value?.contains("@") == false)
    }

    @Test func whenFieldIsHashed_shouldReceiveSixteenHexadecimalCharacters() {
        let recorder = LogRecorder()
        let sut = Log.destination(salt: salt, write: recorder.log.write)

        sut.write(event(.hashed("email", "ada@example.com")))

        let value = recorder.events.first?.fields.map(\.value).first?.rendered
        #expect(value?.count == 16)
        #expect(value?.allSatisfy(\.isHexDigit) == true)
    }

    /// Zero padding in the digest's hexadecimal is load-bearing: without it a byte below 16 renders
    /// as one character, so two different digests could produce the same token.
    @Test func whenManyValuesAreHashed_shouldReceiveSameLengthTokenForEach() {
        let recorder = LogRecorder()
        let sut = Log.destination(salt: salt, write: recorder.log.write)

        for index in 0..<64 {
            sut.write(event(.hashed("value", "value-\(index)")))
        }

        let lengths = Set(recorder.events.compactMap { $0.fields.map(\.value.rendered).first?.count })
        #expect(lengths == [16])
    }

    @Test func whenSameValueIsHashedTwice_shouldProduceTheSameToken() {
        let recorder = LogRecorder()
        let sut = Log.destination(salt: salt, write: recorder.log.write)

        sut.write(event(.hashed("email", "ada@example.com")))
        sut.write(event(.hashed("email", "ada@example.com")))

        let tokens = recorder.events.compactMap { $0.fields.map(\.value).first }
        #expect(tokens.count == 2)
        #expect(tokens[0] == tokens[1])
    }

    @Test func whenTwoFieldsAreHashed_shouldTokeniseEachSeparately() {
        let recorder = LogRecorder()
        let sut = Log.destination(salt: salt, write: recorder.log.write)

        sut.write(event(.hashed("email", "ada@example.com"), .hashed("reference", "ABCD-1")))

        let tokens = recorder.events.first?.fields.map(\.value) ?? []
        #expect(tokens.count == 2)
        #expect(tokens[0] != tokens[1])
    }

    @Test func whenSaltDiffers_shouldProduceADifferentToken() {
        let first = LogRecorder()
        let second = LogRecorder()

        Log.destination(salt: salt, write: first.log.write)
            .write(event(.hashed("email", "ada@example.com")))
        Log.destination(salt: LogSalt(Data("other".utf8)), write: second.log.write)
            .write(event(.hashed("email", "ada@example.com")))

        #expect(first.events.first?.fields.map(\.value).first != second.events.first?.fields.map(\.value).first)
    }

    // MARK: - What is preserved

    @Test func whenClassified_shouldKeepSensitivitySoADestinationCanGroupByIt() {
        let recorder = LogRecorder()
        let sut = Log.destination(salt: salt, secrets: .passThrough, write: recorder.log.write)

        sut.write(event(.open("a", 1), .hashed("b", "x"), .secret("c", "y")))

        #expect(recorder.events.first?.fields.map(\.sensitivity) == [.open, .hashed, .secret])
    }

    @Test func whenClassified_shouldKeepFieldsInWrittenOrder() {
        let recorder = LogRecorder()
        let sut = Log.destination(salt: salt, write: recorder.log.write)

        sut.write(event(.open("second", 2), .hashed("first", "x"), .open("third", 3)))

        #expect(recorder.events.first?.fields.map { String($0.name) } == ["second", "first", "third"])
    }

    @Test func whenClassified_shouldLeaveOpenValuesAlone() {
        let recorder = LogRecorder()
        let sut = Log.destination(salt: salt, write: recorder.log.write)

        sut.write(event(.open("scheme", "ticket")))

        #expect(recorder.events.first?.fields.map(\.value).first == .string("ticket"))
    }

    @Test func whenClassified_shouldLeaveTheEventItselfAlone() {
        let recorder = LogRecorder()
        let sut = Log.destination(salt: salt, write: recorder.log.write)

        sut.write(LogEvent(level: .warning, category: "push", message: "unchanged"))

        #expect(recorder.events.first?.level == .warning)
        #expect(recorder.events.first?.category == "push")
        #expect(recorder.events.first?.message == "unchanged")
    }
}
