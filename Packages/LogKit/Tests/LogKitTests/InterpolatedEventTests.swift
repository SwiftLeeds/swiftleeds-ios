import Foundation
import LogKit
import Testing

/// The whole path an interpolated message takes: written at a call site, enriched by middleware,
/// classified by the destination, then rendered. Each step is covered on its own elsewhere; this
/// covers them composed, which is where the secret-in-the-sentence defect lived.
@Suite struct InterpolatedEventTests {
    private let salt = LogSalt(Data("fixed-for-tests".utf8))

    private func recorded(
        secrets: SecretPolicy,
        _ write: (Log) -> Void
    ) -> LogEvent? {
        let recorder = LogRecorder()
        let sut = Log
            .destination(salt: salt, secrets: secrets, write: recorder.log.write)
            .enriching(with: { [.open("sessionID", "abc123")] })

        write(sut)
        return recorder.events.first
    }

    @Test func whenSecretIsInterpolated_shouldNotReachTheSentence() throws {
        let event = try #require(
            recorded(secrets: .passThrough) { sut in
                sut.error("Token \("supersecret", privacy: .secret) rejected", in: "auth")
            }
        )

        let sentence = event.message.rendered(with: event.fields)

        #expect(sentence == "Token <redacted> rejected")
        #expect(!sentence.contains("supersecret"))
    }

    @Test func whenSecretIsInterpolatedAndRemoved_shouldNotReachTheSentence() throws {
        let event = try #require(
            recorded(secrets: .remove) { sut in
                sut.error("Token \("supersecret", privacy: .secret) rejected", in: "auth")
            }
        )

        #expect(event.message.rendered(with: event.fields) == "Token <redacted> rejected")
    }

    @Test func whenHashedIsInterpolated_shouldRenderTokenNotValue() throws {
        let event = try #require(
            recorded(secrets: .remove) { sut in
                sut.error("Signed in as \("ada@example.com", privacy: .hashed)", in: "auth")
            }
        )

        let sentence = event.message.rendered(with: event.fields)

        #expect(!sentence.contains("ada@example.com"))
        #expect(sentence.hasPrefix("Signed in as "))
    }

    @Test func whenOpenIsInterpolated_shouldRenderTheValue() throws {
        let event = try #require(
            recorded(secrets: .remove) { sut in
                sut.error("Rejected with \(500, privacy: .open)", in: "auth")
            }
        )

        #expect(event.message.rendered(with: event.fields) == "Rejected with 500")
    }

    /// Middleware appends an authored field. It must not be able to fill a gap, however it is named.
    @Test func whenMiddlewareInjectsField_shouldNotFillAnyGap() throws {
        let recorder = LogRecorder()
        let sut = Log
            .destination(salt: salt, write: recorder.log.write)
            .enriching(with: { [.open("0", "impostor")] })

        sut.error("Value was \("real", privacy: .open)", in: "auth")

        let event = try #require(recorder.events.first)
        #expect(event.message.rendered(with: event.fields) == "Value was real")
    }

    @Test func whenEnriched_shouldKeepInterpolatedFieldsAndInjectedOnes() throws {
        let event = try #require(
            recorded(secrets: .remove) { sut in
                sut.error("Rejected with \(500, name: "statusCode", privacy: .open)", in: "auth")
            }
        )

        #expect(event.fields.map { String($0.name) } == ["statusCode", "sessionID"])
    }
}
