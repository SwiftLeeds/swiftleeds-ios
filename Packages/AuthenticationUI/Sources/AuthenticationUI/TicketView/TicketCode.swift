import SwiftUI

/// An attendee's ticket code: drawn and ready to scan, or missing.
package enum TicketCode {
    case drawn(Image)
    case unavailable

    /// Creates the drawn code, or `unavailable` when `content` cannot be encoded.
    @MainActor package init(drawing content: BarcodeContent) {
        self = content.makeImage()
            .map { .drawn(Image(decorative: $0, scale: 1)) }
            ?? .unavailable
    }
}
