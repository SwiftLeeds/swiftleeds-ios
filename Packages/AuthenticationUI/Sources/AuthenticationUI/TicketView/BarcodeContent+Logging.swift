import CoreGraphics
import Dependencies
import LogKit

extension BarcodeContent {
    /// Records that the code could not be drawn, then returns what it drew.
    ///
    /// - Parameter payloadLength: How many characters the code carries. A payload too long for the
    ///   symbology is the likeliest cause, so the length is what a reader can act on.
    package func loggingFailures(payloadLength: Int) -> BarcodeContent {
        BarcodeContent {
            guard let image = makeImage() else {
                // Resolved per call, so a test overriding \.log is honoured.
                @Dependency(\.log) var log
                log.error(
                    """
                    The ticket code could not be drawn: \
                    \(payloadLength, name: "payloadLength", privacy: .open)
                    """,
                    in: .ticket
                )
                return nil
            }
            return image
        }
    }
}
