import SwiftUI
import UIDesign

/// A view that lists a session's speakers under a "Speakers" heading.
///
/// Each person is a row: a large avatar, then the name above the description.
/// The rows sit side by side in equal columns while they fit, and stack at an
/// accessibility text size.
struct CreditedRows: View {
    /// The speakers to list, in order.
    private let speakers: [SamplePerson]

    /// The action that shows a person's page.
    private let showPerson: (SamplePerson) -> Void

    /// The current Dynamic Type size.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// Creates a list of speakers.
    ///
    /// - Parameters:
    ///   - speakers: The speakers to list, in order.
    ///   - showPerson: The action that shows a person's page.
    init(speakers: [SamplePerson], showPerson: @escaping (SamplePerson) -> Void) {
        self.speakers = speakers
        self.showPerson = showPerson
    }

    /// The heading, then the rows.
    var body: some View {
        VStack(alignment: .leading, spacing: .small) {
            Text("Speakers")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            rows
        }
    }
}

// MARK: - Rows

extension CreditedRows {
    /// The rows, in two equal columns while each fits in one, and
    /// stacked when they do not, or at an accessibility text size.
    @ViewBuilder
    private var rows: some View {
        if dynamicTypeSize.isAccessibilitySize {
            stackedRows
        } else {
            EqualColumns(columnGap: CGFloat(Spacing.xLarge), rowGap: CGFloat(Spacing.large)) {
                ForEach(speakers) { row(for: $0) }
            }
        }
    }

    /// The rows, one above the next.
    private var stackedRows: some View {
        VStack(alignment: .leading, spacing: .large) {
            ForEach(speakers) { row(for: $0) }
        }
    }

    /// Returns a button that shows a person's page, with a large avatar beside the text.
    ///
    /// At an accessibility text size the avatar moves above the text.
    ///
    /// - Parameter person: The person the row names.
    /// - Returns: A button that shows the person's page.
    private func row(for person: SamplePerson) -> some View {
        Button {
            showPerson(person)
        } label: {
            arrangement {
                avatar(for: person)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: .xxSmall) {
                    Text(person.name)
                        .font(.headline)
                        .foregroundStyle(.textPrimary)

                    Text(person.detail)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                }
                .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(person.name), \(person.detail)")
    }

    /// The avatar beside the text, or above it at an accessibility text size.
    private var arrangement: AnyLayout {
        if dynamicTypeSize.isAccessibilitySize {
            AnyLayout(VStackLayout(alignment: .leading, spacing: CGFloat(Spacing.medium)))
        } else {
            AnyLayout(HStackLayout(alignment: .center, spacing: CGFloat(Spacing.large)))
        }
    }

    /// Returns a person's initials on a disc with an edge, in quiet type.
    ///
    /// - Parameter person: The person the avatar names.
    /// - Returns: An extra large avatar showing the person's initials.
    private func avatar(for person: SamplePerson) -> some View {
        // The initials disc is the row's own color, so it takes an edge to be
        // seen, as the person page's avatar does.
        Avatar(url: nil, size: .xLarge) {
            QuietInitials(person.nameComponents)
        }
        .overlay {
            Circle().strokeBorder(Color.borderPrimary, lineWidth: CGFloat(BorderWidth.thin))
        }
    }
}
