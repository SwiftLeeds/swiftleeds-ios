import AuthenticationFeature
import Foundation
import SwiftUI

/// The ticket screen's body: the code when it drew, and the way forward when it did not.
struct TicketViewContent: View {
    private let code: TicketCode
    private let reference: String
    private let name: PersonNameComponents

    init(code: TicketCode, reference: String, name: PersonNameComponents) {
        self.code = code
        self.reference = reference
        self.name = name
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 0)

            ticketCode

            identity

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    @ViewBuilder private var ticketCode: some View {
        switch code {
        case .drawn(let image):
            Barcode(image: image)
                .frame(maxWidth: 320)
                .accessibilityElement()
                .accessibilityLabel("Ticket QR code")
                .accessibilityHint("Hold this up to be scanned")
        case .unavailable:
            unavailable
        }
    }

    private var identity: some View {
        VStack(spacing: 4) {
            Text(verbatim: reference)
                .font(.title2.weight(.semibold).monospaced())
                .textSelection(.enabled)
                .accessibilityLabel("Ticket reference \(reference)")

            Text(name.formatted())
                .foregroundStyle(.secondary)
        }
    }

    private var unavailable: some View {
        VStack(spacing: 8) {
            Label("We can't show your QR code", systemImage: "exclamationmark.triangle")

            Text("Show your ticket reference to a member of staff and they'll check you in.")
                .font(.footnote)
        }
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding()
    }
}

#if DEBUG
#Preview("Ready to scan") {
    TicketViewContent(
        code: TicketCode(drawing: .qr(QRCode.Payload(String(Profile.preview.ticketSlug)))),
        reference: Profile.preview.ticketReference,
        name: Profile.preview.name
    )
}

#Preview("Code will not draw") {
    TicketViewContent(
        code: .unavailable,
        reference: Profile.preview.ticketReference,
        name: Profile.preview.name
    )
}
#endif
