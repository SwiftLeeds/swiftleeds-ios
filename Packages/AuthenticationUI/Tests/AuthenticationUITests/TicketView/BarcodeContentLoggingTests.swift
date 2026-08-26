import AuthenticationUI
import Dependencies
import LogKit
import Testing

/// A code that will not draw leaves the attendee holding a ticket that cannot be scanned, and the
/// view shows a card rather than raising anything. This is the only record of it.
@MainActor
@Suite struct BarcodeContentLoggingTests {
    private let undrawable = BarcodeContent.code128("café-ticket-✓")
    private let drawable = BarcodeContent.code128("ABCD-1")

    @Test func whenCodeCannotBeDrawn_shouldLogAtErrorLevel() throws {
        let event = try #require(attempt(undrawable, payloadLength: 15))

        #expect(event.level == .error)
    }

    @Test func whenCodeCannotBeDrawn_shouldLogPayloadLength() throws {
        let event = try #require(attempt(undrawable, payloadLength: 15))

        #expect(event.fields.first { String($0.name) == "payloadLength" }?.value == .integer(15))
    }

    @Test func whenCodeCannotBeDrawn_shouldStillReturnNothingToDraw() {
        let recorder = LogRecorder()

        withDependencies {
            $0.log = recorder.log
        } operation: {
            #expect(undrawable.loggingFailures(payloadLength: 15).makeImage() == nil)
        }
    }

    @Test func whenCodeDraws_shouldLogNothing() {
        let recorder = LogRecorder()

        withDependencies {
            $0.log = recorder.log
        } operation: {
            _ = drawable.loggingFailures(payloadLength: 6).makeImage()
        }

        #expect(recorder.events.isEmpty)
    }

    @Test func whenCodeDraws_shouldReturnTheSameImage() {
        let recorder = LogRecorder()

        withDependencies {
            $0.log = recorder.log
        } operation: {
            let undecorated = drawable.makeImage()
            let decorated = drawable.loggingFailures(payloadLength: 6).makeImage()

            #expect(decorated?.width == undecorated?.width)
            #expect(decorated?.height == undecorated?.height)
        }
    }

    private func attempt(_ content: BarcodeContent, payloadLength: Int) -> LogEvent? {
        let recorder = LogRecorder()

        withDependencies {
            $0.log = recorder.log
        } operation: {
            _ = content.loggingFailures(payloadLength: payloadLength).makeImage()
        }

        // Pinned here rather than per test, so a decorator that records twice fails everything.
        #expect(recorder.events.count == 1)
        return recorder.events.first
    }
}
