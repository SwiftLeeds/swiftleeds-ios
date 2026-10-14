import SwiftUI
import UIDesign

/// A view that stands in for the ticket pass: a raised card with a role band, a name and a code.
///
/// The pass is content, so it has no glass. Its shadow falls below it rather
/// than around it, which reads as a card lying on the screen.
struct MockPass: View {
    /// The ticket the pass shows.
    let ticket: SampleTicket

    /// Whether the role band draws the role's texture.
    let bandVariant: BandVariant

    /// Whether the screen is light or dark, which decides the shadow.
    @Environment(\.colorScheme) private var colorScheme

    /// The name of the conference.
    private static let conference = "SwiftLeeds 2026"

    /// The days the conference runs.
    private static let dates = "8 to 9 October"

    /// How far the shadow blurs.
    private static let shadowRadius: CGFloat = 10

    /// How far the shadow falls. It is at least the blur, so none shows above.
    private static let shadowOffset: CGFloat = 12

    /// How strong the shadow is in light mode.
    private static let lightShadowOpacity: Double = 0.18

    /// How strong the shadow is in dark mode.
    private static let darkShadowOpacity: Double = 0.10

    /// The shape of the pass.
    private var shape: some Shape {
        RoundedRectangle(cornerRadius: CGFloat(CornerRadius.xLarge), style: .continuous)
    }

    /// The color of the shadow: black in light mode, white in dark mode.
    private var shadowColor: Color {
        switch colorScheme {
        case .dark: .white.opacity(Self.darkShadowOpacity)
        default: .black.opacity(Self.lightShadowOpacity)
        }
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
        .background {
            shape
                .fill(.secondarySurface)
                .shadow(color: shadowColor, radius: Self.shadowRadius, x: 0, y: Self.shadowOffset)
        }
    }

    /// The band, the conference and the holder, which VoiceOver reads as one.
    private var identity: some View {
        VStack(alignment: .leading, spacing: 0) {
            RoleBand(role: ticket.role, variant: bandVariant)

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
