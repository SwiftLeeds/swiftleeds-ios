import SwiftUI
import UIDesign

/// A view that stands in for the ticket pass: a card with a role band, a name and a code.
///
/// The pass is content, so it has no glass and no shadow.
struct MockPass: View {
    /// The ticket the pass shows.
    let ticket: SampleTicket

    /// Whether the role band draws the role's texture.
    let bandVariant: BandVariant

    /// The name of the conference.
    private static let conference = "SwiftLeeds 2026"

    /// The days the conference runs.
    private static let dates = "8 to 9 October"

    /// The smallest corner radius the role band takes.
    ///
    /// The band's top corners follow the pass's corners. Its bottom corners are
    /// far from any corner of the pass, so without this they would be square.
    private static let bandMinimumRadius: Edge.Corner.Style = 12

    /// The shape of the pass.
    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: CGFloat(CornerRadius.xLarge), style: .continuous)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            identity

            VStack(spacing: .large) {
                codeOrNotice
                reference
            }
            .frame(maxWidth: .infinity)
            .padding(.large)
        }
        .clipShape(shape)
        .containerShape(shape)
        .background(.secondarySurface, in: shape)
    }

    /// The band, the conference and the holder, which VoiceOver reads as one.
    private var identity: some View {
        VStack(alignment: .leading, spacing: 0) {
            RoleBand(role: ticket.role, variant: bandVariant)
                .clipShape(ConcentricRectangle(corners: .concentric(minimum: Self.bandMinimumRadius)))
                .padding(.small)

            VStack(alignment: .leading, spacing: .large) {
                conference
                holder
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.large)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(identityLabel)
    }

    /// What VoiceOver says for the band, the conference and the holder together.
    private var identityLabel: String {
        [
            "\(ticket.role.name) ticket",
            ticket.holderName,
            ticket.company,
            Self.conference,
            Self.dates,
            ticket.admits,
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
    }

    /// The conference's name and dates.
    private var conference: some View {
        VStack(alignment: .leading, spacing: .xxSmall) {
            Text(Self.conference)
                .font(.headline)
                .foregroundStyle(.textPrimary)

            Text(Self.dates)
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
        }
    }

    /// The holder's name, the largest text on the pass, with what the ticket admits.
    private var holder: some View {
        VStack(alignment: .leading, spacing: .xxSmall) {
            Text(ticket.holderName)
                .font(.title.bold())
                .foregroundStyle(.textPrimary)

            if let company = ticket.company {
                Text(company)
                    .font(.body)
                    .foregroundStyle(.textSecondary)
            }

            Text(ticket.admits)
                .font(.body)
                .foregroundStyle(.textSecondary)
        }
    }

    /// The QR code, or a notice when the code will not draw.
    @ViewBuilder private var codeOrNotice: some View {
        if let image = ticket.code.flatMap(TicketCode.image(for:)) {
            TicketCode(image: image)
        } else {
            notice
        }
    }

    /// What the pass says in place of a code that will not draw.
    private var notice: some View {
        VStack(alignment: .leading, spacing: .small) {
            Label("We cannot show your QR code", systemImage: "exclamationmark.triangle")
                .font(.headline)
                .foregroundStyle(.textPrimary)

            Text("Show this reference to a member of staff at the door.")
                .font(.subheadline)
                .foregroundStyle(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// The ticket's reference, which a person can select and copy.
    private var reference: some View {
        Text(ticket.reference)
            .font(.body.monospaced())
            .foregroundStyle(.textPrimary)
            .textSelection(.enabled)
            .accessibilityLabel("Ticket reference \(ticket.reference)")
    }
}
