import SwiftUI
import UIDesign

/// A view that summarizes one sponsor in a row.
///
/// The row shows the name. The number of open roles shows only where the
/// caller asks for it.
struct SponsorRow: View {
    /// The sponsor this row describes.
    let sponsor: SampleSponsor

    /// Whether the row says how many jobs the sponsor is hiring for.
    var showsOpenRoles = false

    /// How wide and tall the logo's square is.
    ///
    /// A logo identifies the company, so it is content rather than decoration
    /// and grows with the text beside it.
    @ScaledMetric(relativeTo: .headline) private var logoSide: CGFloat = 56

    var body: some View {
        ReflowingStack {
            logo

            VStack(alignment: .leading, spacing: .xxSmall) {
                Text(sponsor.name)
                    .font(.headline)
                    .foregroundStyle(.textPrimary)

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

    /// The shape of the logo's square.
    private var logoShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: CGFloat(CornerRadius.small), style: .continuous)
    }

    /// The square that stands in for the company's logo.
    ///
    /// The edge keeps the square visible on a surface of the same color.
    private var logo: some View {
        logoShape
            .fill(.tertiarySurface)
            .strokeBorder(.borderPrimary, lineWidth: CGFloat(BorderWidth.thin))
            .frame(width: logoSide, height: logoSide)
            .overlay {
                Text(String(sponsor.name.prefix(1)))
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.textSecondary)
            }
            .accessibilityHidden(true)
    }
}
