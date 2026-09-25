import SwiftUI
import UIDesign

/// A view that says where the conference is and what a person needs there.
struct VenueScreen: View {
    /// How large this person has asked text to be.
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// How wide the column holding each row's symbol is.
    ///
    /// It grows with the text size, so the titles stay in one column when the
    /// symbols grow.
    @ScaledMetric(relativeTo: .body) private var symbolWidth = CGFloat(IconSize.large)

    /// How far a separator between two rows sits from the group's leading edge.
    ///
    /// It lines up with the title rather than with the group, so the symbols
    /// read as one column. At an accessibility size the symbol moves above the
    /// title, so there is no column left to line up with.
    private var separatorInset: CGFloat {
        guard !dynamicTypeSize.isAccessibilitySize else { return CGFloat(Spacing.large) }
        return CGFloat(Spacing.large) + symbolWidth + CGFloat(Spacing.medium)
    }

    /// How a row arranges its symbol, its text and its trailing mark.
    ///
    /// At an accessibility size the three stack, which gives the text the whole
    /// width instead of the share a symbol column leaves it.
    private var rowLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: CGFloat(Spacing.small)))
            : AnyLayout(HStackLayout(alignment: .center, spacing: CGFloat(Spacing.medium)))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: .large) {
                    venue
                    food
                    section("Practical", resources: SampleResource.practical)
                    section("SwiftLeeds", resources: SampleResource.swiftLeeds)
                }
                .padding(.horizontal, .large)
                .padding(.bottom, .large)
            }
            .background { AmbientBackground() }
            .navigationTitle("Venue")
            .navigationDestination(for: SampleResource.self) { resource in
                NotYetDesigned(destination: .venue)
                    .navigationTitle(resource.title)
            }
        }
    }

    /// Where the conference is, with the weather beside its name.
    private var venue: some View {
        VStack(alignment: .leading, spacing: .small) {
            rowLayout {
                heading(SampleVenue.name)
                    .frame(maxWidth: .infinity, alignment: .leading)

                weather
            }

            VStack(spacing: 0) {
                row(SampleResource.address)

                Divider().padding(.leading, separatorInset)

                fact("Rooms", value: SampleVenue.rooms)
            }
            .contentGroup()
        }
    }

    /// How warm it is at the venue.
    private var weather: some View {
        Label(SampleVenue.temperature, systemImage: SampleVenue.weatherSymbol)
            .font(.subheadline)
            .foregroundStyle(.textSecondary)
            .accessibilityLabel(SampleVenue.weather)
    }

    /// What the venue feeds people, and the voucher lunch asks them to carry.
    private var food: some View {
        VStack(alignment: .leading, spacing: .small) {
            heading("Food and drink")

            MockNotice(
                symbol: "ticket",
                message: SampleVenue.lunch,
                actionTitle: SampleVenue.lunchAction
            )

            fact("Breaks", value: SampleVenue.breaks)
                .contentGroup()
        }
    }

    /// Returns one section of resources, each on its own row.
    ///
    /// - Parameters:
    ///   - name: What the section is called.
    ///   - resources: The pages and screens the section points at.
    private func section(_ name: String, resources: [SampleResource]) -> some View {
        VStack(alignment: .leading, spacing: .small) {
            heading(name)

            VStack(spacing: 0) {
                ForEach(Array(resources.enumerated()), id: \.element.id) { index, resource in
                    row(resource)

                    if index < resources.count - 1 {
                        Divider().padding(.leading, separatorInset)
                    }
                }
            }
            .contentGroup()
        }
    }

    /// Returns one section's heading.
    ///
    /// - Parameter name: What the section is called.
    private func heading(_ name: String) -> some View {
        Text(name)
            .font(.title3.weight(.semibold))
            .foregroundStyle(.textPrimary)
    }

    /// Returns one resource as a row that opens it.
    ///
    /// A screen inside the app pushes, so it takes a chevron. A page on the web
    /// leaves the app, so it takes an arrow.
    ///
    /// - Parameter resource: The page or screen the row opens.
    @ViewBuilder
    private func row(_ resource: SampleResource) -> some View {
        switch resource.destination {
        case .screen:
            NavigationLink(value: resource) {
                line(resource, mark: "chevron.right")
            }
            .buttonStyle(.plain)

        case .page:
            Button {} label: {
                line(resource, mark: "arrow.up.right")
            }
            .buttonStyle(.plain)
            // The gallery opens nothing, so the trait is what tells VoiceOver
            // this row leaves the app. The arrow says it only to the eye.
            .accessibilityAddTraits(.isLink)
        }
    }

    /// Returns the parts every row draws, whatever it opens.
    ///
    /// - Parameters:
    ///   - resource: The page or screen the row opens.
    ///   - mark: The SF Symbol that says what tapping the row does.
    private func line(_ resource: SampleResource, mark: String) -> some View {
        rowLayout {
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

            Image(systemName: mark)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.textTertiary)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, .large)
        .padding(.vertical, .medium)
        .frame(minHeight: CGFloat(IconSize.xxLarge))
        .contentShape(.rect)
    }

    /// Returns one fact, with its label above its value.
    ///
    /// - Parameters:
    ///   - label: What the fact is about.
    ///   - value: The fact itself.
    private func fact(_ label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: .xxSmall) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.textSecondary)

            Text(value)
                .font(.body)
                .foregroundStyle(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, .large)
        .padding(.vertical, .medium)
    }
}
