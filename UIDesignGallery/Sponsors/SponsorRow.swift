import SwiftUI
import UIDesign

/// A view that summarizes one sponsor in the sponsors list.
struct SponsorRow: View {
    /// The sponsor this row describes.
    let sponsor: SampleSponsor

    /// How wide and tall the logo's square is.
    static let logoSide: CGFloat = 56

    /// How far a separator between two rows sits from the card's leading edge.
    ///
    /// It lines up with the name rather than with the card, so the logos read
    /// as one column.
    static var separatorInset: CGFloat {
        CGFloat(Spacing.large) + logoSide + CGFloat(Spacing.medium)
    }

    var body: some View {
        HStack(spacing: .medium) {
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

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.textTertiary)
        }
        .padding(.horizontal, .large)
        .padding(.vertical, .medium)
    }

    /// The square that stands in for the company's logo.
    private var logo: some View {
        RoundedRectangle(cornerRadius: CGFloat(CornerRadius.small), style: .continuous)
            .fill(.tertiarySurface)
            .frame(width: Self.logoSide, height: Self.logoSide)
            .overlay {
                Text(String(sponsor.name.prefix(1)))
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.textSecondary)
            }
            .accessibilityHidden(true)
    }
}
