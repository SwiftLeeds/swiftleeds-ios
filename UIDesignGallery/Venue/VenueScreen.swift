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

    var body: some View {
        NavigationStack {
            List {
                venue
                food
                section("Practical", resources: SampleResource.practical)
                section("SwiftLeeds", resources: SampleResource.swiftLeeds)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
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
        Section {
            row(SampleResource.address)
            fact("Rooms", value: SampleVenue.rooms)
        } header: {
            ReflowingStack {
                Text(SampleVenue.name)
                    .frame(maxWidth: .infinity, alignment: .leading)

                weather
            }
        }
        .listRowBackground(ContentSurface())
    }

    /// How warm it is at the venue.
    ///
    /// It takes the heading's own size and color, so the two read as one line.
    private var weather: some View {
        Label(SampleVenue.temperature, systemImage: SampleVenue.weatherSymbol)
            .accessibilityLabel(SampleVenue.weather)
    }

    /// What the venue feeds people, and the voucher lunch asks them to carry.
    ///
    /// The notice draws its own surface, so its row clears the one the section
    /// would otherwise put behind it.
    private var food: some View {
        Group {
            Section("Food and drink") {
                MockNotice(
                    symbol: "ticket",
                    message: SampleVenue.lunch,
                    actionTitle: SampleVenue.lunchAction
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section {
                fact("Breaks", value: SampleVenue.breaks)
            }
            .listRowBackground(ContentSurface())
        }
    }

    /// Returns one section of resources, each on its own row.
    ///
    /// - Parameters:
    ///   - name: What the section is called.
    ///   - resources: The pages and screens the section points at.
    private func section(_ name: String, resources: [SampleResource]) -> some View {
        Section(name) {
            ForEach(resources) { resource in
                row(resource)
            }
        }
        .listRowBackground(ContentSurface())
    }

    /// Returns one resource as a row that opens it.
    ///
    /// A screen inside the app pushes, so `List` draws its chevron. A page on
    /// the web leaves the app, so the row draws an arrow of its own.
    ///
    /// - Parameter resource: The page or screen the row opens.
    @ViewBuilder
    private func row(_ resource: SampleResource) -> some View {
        switch resource.destination {
        case .screen:
            NavigationLink(value: resource) {
                line(resource, mark: nil)
            }

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
    ///   - mark: The SF Symbol that says tapping the row leaves the app, or
    ///     `nil` where `List` draws the mark itself.
    private func line(_ resource: SampleResource, mark: String?) -> some View {
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
    }
}
