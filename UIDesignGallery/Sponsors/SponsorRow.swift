import SwiftUI
import UIDesign

/// A view that summarizes one sponsor in a row.
///
/// The row shows the logo, the name and the tagline. The number of open roles
/// shows only where the caller asks for it.
struct SponsorRow: View {
    /// How wide and tall the logo's square is before the text size scales it.
    private static let baseLogoSide: CGFloat = 56

    /// The sponsor this row describes.
    let sponsor: SampleSponsor

    /// Whether the row says how many jobs the sponsor is hiring for.
    var showsOpenRoles = false

    /// How wide and tall the logo's square is.
    ///
    /// A logo identifies the company, so it is content rather than decoration
    /// and grows with the text beside it.
    @ScaledMetric(relativeTo: .headline) private var logoSide = SponsorRow.baseLogoSide

    var body: some View {
        ReflowingStack {
            SponsorLogoTile(logo: sponsor.logo, side: logoSide)

            VStack(alignment: .leading, spacing: .xxSmall) {
                Text(sponsor.name)
                    .font(.headline)
                    .foregroundStyle(.textPrimary)

                if let tagline = sponsor.tagline {
                    Text(tagline)
                        .font(.body)
                        .foregroundStyle(.textSecondary)
                }

                if showsOpenRoles, let openRoles = sponsor.openRoles {
                    Text(openRoles)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
        }
    }
}
