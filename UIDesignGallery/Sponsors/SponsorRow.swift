import SwiftUI
import UIDesign

/// A view that summarizes one sponsor in the sponsors list.
struct SponsorRow: View {
    /// How large this person has asked text to be.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// The sponsor this row describes.
    let sponsor: SampleSponsor

    /// How wide and tall the logo's square is.
    ///
    /// A logo identifies the company, so it is content rather than decoration
    /// and grows with the text beside it.
    @ScaledMetric(relativeTo: .headline) private var logoSide: CGFloat = 56

    /// How a row arranges its logo and its text.
    ///
    /// At an accessibility size the two stack, which gives the name the whole
    /// width instead of the share a grown logo leaves it.
    private var rowLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: CGFloat(Spacing.small)))
            : AnyLayout(HStackLayout(alignment: .center, spacing: CGFloat(Spacing.medium)))
    }

    var body: some View {
        rowLayout {
            logo

            VStack(alignment: .leading, spacing: .xxSmall) {
                Text(sponsor.name)
                    .font(.headline)
                    .foregroundStyle(.textPrimary)

                if let detail = sponsor.detail {
                    Text(detail)
                        .font(.body)
                        .foregroundStyle(.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
        }
    }

    /// The square that stands in for the company's logo.
    private var logo: some View {
        RoundedRectangle(cornerRadius: CGFloat(CornerRadius.small), style: .continuous)
            .fill(.tertiarySurface)
            .frame(width: logoSide, height: logoSide)
            .overlay {
                Text(String(sponsor.name.prefix(1)))
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.textSecondary)
            }
            .accessibilityHidden(true)
    }
}
