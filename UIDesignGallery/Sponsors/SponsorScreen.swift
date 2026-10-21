import SwiftUI
import UIDesign

/// A view that shows who a sponsor is, what it is hiring for and where to find it.
///
/// The roles section appears only when the sponsor has a job to advertise.
struct SponsorScreen: View {
    /// How wide and tall the header's logo is before the text size scales it.
    private static let baseLogoSide: CGFloat = 96

    /// The sponsor this screen describes.
    let sponsor: SampleSponsor

    /// How wide and tall the header's logo is.
    ///
    /// A logo identifies the company, so it is content rather than decoration
    /// and grows with the text beside it.
    @ScaledMetric(relativeTo: .title2) private var logoSide = SponsorScreen.baseLogoSide

    var body: some View {
        List {
            Section {
                header
                    // The header is the screen's subject, not one of its rows,
                    // so it sits on the page rather than on a card. It keeps
                    // the list's own row insets, so it lines up with the rows.
                    .listRowBackground(Color.clear)
            }

            roles

            Section("Links") {
                ResourceRow(resource: sponsor.website.resource)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(sponsor.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .tint(.textPrimary)
            }
        }
    }

    /// Who the sponsor is, and how much it gives the conference.
    ///
    /// The logo is hidden from VoiceOver, because the name sits directly below
    /// it. The rest reads as one element: the name, the tagline, then the tier.
    private var header: some View {
        VStack(alignment: .leading, spacing: .medium) {
            SponsorLogoTile(logo: sponsor.logo, side: logoSide, cornerRadius: .large)

            VStack(alignment: .leading, spacing: .xxSmall) {
                Text(sponsor.name)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.textPrimary)

                if let tagline = sponsor.tagline {
                    Text(tagline)
                        .font(.body)
                        .foregroundStyle(.textPrimary)
                }

                Text(sponsor.standing)
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
            }
            .accessibilityElement(children: .combine)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .multilineTextAlignment(.leading)
        .padding(.vertical, .large)
    }

    /// The jobs the sponsor is hiring for, if any.
    @ViewBuilder
    private var roles: some View {
        if !sponsor.jobs.isEmpty {
            Section("Open roles") {
                ForEach(sponsor.jobs) { job in
                    SponsorJobRow(job: job)
                }
            }
        }
    }
}
