import SwiftUI

/// An attendee's ticket code: drawn and ready to scan, or missing.
enum TicketCode {
    case drawn(Image)
    case unavailable

    /// Creates the drawn code, or `unavailable` when `content` cannot be encoded.
    @MainActor init(drawing content: BarcodeContent) {
        self = content.makeImage()
            .map { .drawn(Image(decorative: $0, scale: 1)) }
            ?? .unavailable
    }
}
