import SwiftUI
import UIDesign

/// A view that says where the conference is and what a person needs there.
struct VenueScreen: View {
    var body: some View {
        NavigationStack {
            List {
                venue
                food
                section("Practical", resources: SampleResource.practical)
                section("SwiftLeeds", resources: SampleResource.swiftLeeds)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Venue")
            .navigationDestination(for: SampleResource.self) { resource in
                NotYetDesigned(symbol: resource.symbol)
                    .navigationTitle(resource.title)
            }
        }
    }

    /// Where the conference is, with the weather beside its name.
    private var venue: some View {
        Section {
            ResourceRow(resource: .address)
            fact("Rooms", value: SampleVenue.rooms)
        } header: {
            ReflowingStack {
                Text(SampleVenue.name)
                    .frame(maxWidth: .infinity, alignment: .leading)

                weather
            }
        }
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
    /// The notice pads itself, so its row clears the insets the section would
    /// otherwise add on top.
    private var food: some View {
        Group {
            Section("Food and drink") {
                MockNotice(
                    symbol: "ticket",
                    message: SampleVenue.lunch,
                    actionTitle: SampleVenue.lunchAction,
                )
                .listRowInsets(EdgeInsets())
            }

            Section {
                fact("Breaks", value: SampleVenue.breaks)
            }
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
                ResourceRow(resource: resource)
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
