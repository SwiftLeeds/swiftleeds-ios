import SwiftUI
import UIDesign

/// A view that lists a session's speakers under a "Speakers" heading.
///
/// Each speaker is a row: a large avatar, then the name above the description.
/// The rows sit side by side in equal columns while they fit, and stack at an
/// accessibility text size.
struct SpeakerRows: View {
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

extension SpeakerRows {
    /// The speakers' rows, in two equal columns while each fits in one, and
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

    /// The speakers' rows, one above the next.
    private var stackedRows: some View {
        VStack(alignment: .leading, spacing: .large) {
            ForEach(speakers) { row(for: $0) }
        }
    }

    /// Returns a button that shows a speaker's page, with a large avatar beside the text.
    ///
    /// At an accessibility text size the avatar moves above the text.
    ///
    /// - Parameter speaker: The speaker the row names.
    /// - Returns: A button that shows the speaker's page.
    private func row(for speaker: SamplePerson) -> some View {
        Button {
            showPerson(speaker)
        } label: {
            arrangement {
                avatar(for: speaker)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: .xxSmall) {
                    Text(speaker.name)
                        .font(.headline)
                        .foregroundStyle(.textPrimary)

                    Text(speaker.detail)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                }
                .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(speaker.name), \(speaker.detail)")
    }

    /// The avatar beside the text, or above it at an accessibility text size.
    private var arrangement: AnyLayout {
        if dynamicTypeSize.isAccessibilitySize {
            AnyLayout(VStackLayout(alignment: .leading, spacing: CGFloat(Spacing.medium)))
        } else {
            AnyLayout(HStackLayout(alignment: .center, spacing: CGFloat(Spacing.large)))
        }
    }

    /// Returns a speaker's initials on a disc with an edge, in quiet type.
    ///
    /// - Parameter speaker: The speaker the avatar names.
    /// - Returns: An extra large avatar showing the speaker's initials.
    private func avatar(for speaker: SamplePerson) -> some View {
        // The initials disc is the row's own color, so it takes an edge to be
        // seen, as the person page's avatar does.
        Avatar(url: nil, size: .xLarge) {
            QuietInitials(speaker.nameComponents)
        }
        .overlay {
            Circle().strokeBorder(Color.borderPrimary, lineWidth: CGFloat(BorderWidth.thin))
        }
    }
}
