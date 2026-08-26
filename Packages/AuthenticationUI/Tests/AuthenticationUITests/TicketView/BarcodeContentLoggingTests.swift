import AuthenticationUI
import CoreGraphics
import Dependencies
import LogKit
import Testing

/// A code that will not draw leaves the attendee holding a ticket that cannot be scanned, and the
/// view shows a card rather than raising anything. This is the only record of it.
@MainActor
@Suite struct BarcodeContentLoggingTests {
    @Test func whenCodeCannotBeDrawn_shouldLogAtErrorLevel() throws {
        let event = try #require(attempt(.undrawable, payloadBytes: 26))

        #expect(event.level == .error)
    }

    @Test func whenCodeCannotBeDrawn_shouldLogPayloadBytes() throws {
        let event = try #require(attempt(.undrawable, payloadBytes: 26))

        #expect(event.fields.first { String($0.name) == "payloadBytes" }?.value == .integer(26))
    }

    @Test func whenCodeCannotBeDrawn_shouldStillReturnNothingToDraw() {
        withDependencies {
            $0.log = LogRecorder().log
        } operation: {
            let sut = BarcodeContent.undrawable.loggingFailures(payloadBytes: 26)

            #expect(sut.makeImage() == nil)
        }
    }

    @Test func whenCodeDraws_shouldLogNothing() throws {
        let recorder = LogRecorder()
        let swatch = try #require(CGImage.swatch)

        withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = BarcodeContent.drawing(swatch).loggingFailures(payloadBytes: 26)
            _ = sut.makeImage()
        }

        #expect(recorder.events.isEmpty)
    }

    // The decorator observes and passes through, so returning an image of its own making, even a
    // correct redraw, would break that contract.
    @Test func whenCodeDraws_shouldReturnThatExactImage() throws {
        let swatch = try #require(CGImage.swatch)

        withDependencies {
            $0.log = LogRecorder().log
        } operation: {
            let sut = BarcodeContent.drawing(swatch).loggingFailures(payloadBytes: 26)

            #expect(sut.makeImage() === swatch)
        }
    }

    private func attempt(_ content: BarcodeContent, payloadBytes: Int) -> LogEvent? {
        let recorder = LogRecorder()

        withDependencies {
            $0.log = recorder.log
        } operation: {
            let sut = content.loggingFailures(payloadBytes: payloadBytes)
            _ = sut.makeImage()
        }

        // Pinned here rather than per test, so a decorator that records twice fails everything.
        #expect(recorder.events.count == 1)
        return recorder.events.first
    }
}

private extension BarcodeContent {
    /// Content that cannot draw, without depending on any symbology's rejection rules.
    static var undrawable: BarcodeContent { BarcodeContent { nil } }

    static func drawing(_ image: CGImage) -> BarcodeContent { BarcodeContent { image } }
}

private extension CGImage {
    /// One opaque pixel. The tests care which image comes back, never what it shows.
    static let swatch: CGImage? = CGContext(
        data: nil,
        width: 1,
        height: 1,
        bitsPerComponent: 8,
        bytesPerRow: 1,
        space: CGColorSpaceCreateDeviceGray(),
        bitmapInfo: CGImageAlphaInfo.none.rawValue
    )?.makeImage()
}
