import SwiftUI
import UIDesign

/// A view that shows a ticket and the first platinum sponsor.
///
/// With room, the pass sits beside the sponsor. Without it, the sponsor falls
/// below the pass. The layout asks which fits rather than which device it is on.
struct TicketScreen: View {
    /// The ticket to show.
    let ticket: SampleTicket

    /// Whether the role band draws the role's texture.
    var bandVariant: BandVariant = .plain

    /// How wide the pass is when it sits beside the sponsor.
    private static let passWidth: CGFloat = 400

    /// The least width the sponsor needs beside the pass.
    private static let sponsorMinimumWidth: CGFloat = 280

    /// The most width the pass takes when it has a column to itself.
    private static let passMaximumWidth: CGFloat = 440

    var body: some View {
        ScrollView {
            ViewThatFits(in: .horizontal) {
                twoColumns
                oneColumn
            }
            .padding(.large)
        }
    }

    /// The pass on the leading side and the sponsor on the trailing side.
    private var twoColumns: some View {
        HStack(alignment: .top, spacing: .xLarge) {
            MockPass(ticket: ticket, bandVariant: bandVariant)
                .frame(width: Self.passWidth)

            sponsor
                .frame(
                    minWidth: Self.sponsorMinimumWidth,
                    idealWidth: Self.sponsorMinimumWidth,
                    maxWidth: .infinity,
                    alignment: .leading,
                )
        }
    }

    /// The pass, then the sponsor below it.
    private var oneColumn: some View {
        VStack(spacing: .xLarge) {
            MockPass(ticket: ticket, bandVariant: bandVariant)
                .frame(maxWidth: Self.passMaximumWidth)

            sponsor
                .frame(maxWidth: Self.passMaximumWidth, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }

    /// The heading and the first platinum sponsor.
    private var sponsor: some View {
        VStack(alignment: .leading, spacing: .small) {
            if let platinum = SampleSponsor.sponsors(in: .platinum).first {
                Text(platinum.standing)
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)

                SponsorRow(sponsor: platinum)
            }
        }
    }
}
