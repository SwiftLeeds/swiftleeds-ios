import SwiftUI
import UIDesign

/// A view that lists the ways to reach the people who run the conference.
///
/// It has one section after the introduction, and the introduction's
/// sentence is what explains it, so the section carries no footer.
struct ContactScreen: View {
    var body: some View {
        List {
            Section {
                CategoryIntroduction(category: .contact)
            }

            Section {
                ForEach(SampleResource.contact) { resource in
                    ResourceRow(resource: resource)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(SettingsCategory.contact.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
