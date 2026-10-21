import SwiftUI
import UIDesign

/// A view that opens a job's page on the web.
///
/// The row leaves the app, so it draws an arrow of its own at the trailing end.
struct SponsorJobRow: View {
    /// The name of the SF Symbol that stands for a job's place.
    private static let locationSymbol = "mappin.and.ellipse"

    /// The character that joins the symbol to the place without a line break.
    private static let noBreakSpace = "\u{00A0}"

    /// The job the row opens.
    let job: SampleJob

    var body: some View {
        Button {
        } label: {
            ReflowingStack {
                VStack(alignment: .leading, spacing: .xxSmall) {
                    Text(job.title)
                        .font(.headline)
                        .foregroundStyle(.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(
                        "\(Image(systemName: Self.locationSymbol))\(Self.noBreakSpace)\(job.location)"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }

                Image(systemName: "arrow.up.forward")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.textTertiary)
                    .accessibilityHidden(true)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isLink)
    }
}
