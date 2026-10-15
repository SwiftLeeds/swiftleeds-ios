import SwiftUI
import UIDesign

/// A view that opens the page or the screen a resource names.
///
/// A screen inside the app pushes, so `List` draws its chevron. A page on the
/// web leaves the app, so the row draws an arrow of its own.
struct ResourceRow: View {
    /// The page or screen the row opens.
    let resource: SampleResource

    /// How large this person has asked text to be.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// How wide the column holding the row's symbol is.
    ///
    /// It grows with the text size, so the titles stay in one column when the
    /// symbols grow.
    @ScaledMetric(relativeTo: .body) private var symbolWidth = CGFloat(IconSize.large)

    @ViewBuilder
    var body: some View {
        switch resource.destination {
        case .screen:
            NavigationLink(value: resource) {
                line(mark: nil)
            }

        case .page:
            Button {
            } label: {
                line(mark: "arrow.up.forward")
            }
            .buttonStyle(.plain)
            // The gallery opens nothing, so the trait is what tells VoiceOver
            // this row leaves the app. The arrow says it only to the eye.
            .accessibilityAddTraits(.isLink)
        }
    }

    /// Returns the parts every row draws, whatever it opens.
    ///
    /// - Parameter mark: The SF Symbol that says tapping the row leaves the
    ///   app, or `nil` where `List` draws the mark itself.
    private func line(mark: String?) -> some View {
        ReflowingStack {
            Image(systemName: resource.symbol)
                .font(.body)
                .foregroundStyle(.textSecondary)
                .frame(width: dynamicTypeSize.isAccessibilitySize ? nil : symbolWidth)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: .xxSmall) {
                Text(resource.title)
                    .font(.headline)
                    .foregroundStyle(.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                if let detail = resource.detail {
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }

            if let mark {
                Image(systemName: mark)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.textTertiary)
                    .accessibilityHidden(true)
            }
        }
    }
}
