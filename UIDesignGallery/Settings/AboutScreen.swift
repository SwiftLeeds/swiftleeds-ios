import SwiftUI
import UIDesign

/// A view that says who runs the conference, what it asks of people, and
/// where it publishes.
///
/// The version sits in the last section's footer, so no row has to carry it.
struct AboutScreen: View {
    /// Which build of the app this is.
    private static let version = "Version 3.0.1 (412)"

    var body: some View {
        List {
            Section {
                CategoryIntroduction(category: .about)
            }

            Section {
                ForEach(SampleResource.policies) { resource in
                    ResourceRow(resource: resource)
                }
            }

            Section {
                ForEach(SampleResource.outreach) { resource in
                    ResourceRow(resource: resource)
                }
            } header: {
                Text("Find us online")
            } footer: {
                Text(Self.version)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(SettingsCategory.about.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
