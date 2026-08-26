import Dependencies
import LogKit

extension BarcodeContent {
    /// Records that the code could not be drawn, then returns what it drew.
    ///
    /// - Parameter payloadBytes: How many bytes the code carries, which is what a symbology's
    ///   capacity is measured in.
    package func loggingFailures(payloadBytes: Int) -> BarcodeContent {
        BarcodeContent {
            guard let image = makeImage() else {
                // Resolved per call, so a test override is seen.
                @Dependency(\.log) var log
                log.error(
                    """
                    The ticket code could not be drawn: \
                    \(payloadBytes, name: "payloadBytes", privacy: .open)
                    """,
                    in: .ticket
                )
                return nil
            }
            return image
        }
    }
}
