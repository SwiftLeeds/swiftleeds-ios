import SwiftUI
import UIDesign

/// A view that holds what a person can change about the app.
struct SettingsScreen: View {
    /// The person this screen's account section names.
    let attendee: SampleAttendee

    /// The kinds of session a reminder can cover.
    ///
    /// These are display text, for the reason `SampleSession` gives.
    private static let reminderKinds = ["Talks", "Lightning talks", "Workshops"]

    /// What iOS does once a person saves more sessions than it can hold.
    private static let reminderLimit = """
        iOS keeps up to 64 reminders waiting. Sessions past that get none.
        """

    /// Which build of the app this is.
    private static let version = "Version 3.0.1 (412)"

    /// The icon this person gives the app.
    @State private var icon: SampleAppIcon = .classic

    /// How light or dark this person asks the app to be.
    @State private var appearance: SampleAppearance = .automatic

    /// The kinds of session this person wants a reminder for.
    @State private var remindedKinds: Set<String> = ["Talks"]

    var body: some View {
        List {
            account
            appIcon
            appearanceChoice
            reminders
            about
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
    }

    /// Who this person is, and the way to their own profile.
    private var account: some View {
        Section {
            NavigationLink(value: attendee) {
                Nameplate(attendee.name, detail: attendee.detail) {
                    Avatar(url: nil, fallback: .initials(attendee.nameComponents))
                }
            }
        }
    }

    /// The icon the app wears on the Home Screen.
    private var appIcon: some View {
        Picker("App icon", selection: $icon) {
            ForEach(SampleAppIcon.allCases) { option in
                ReflowingStack {
                    MockAppIcon(icon: option)

                    Text(option.title)
                        .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
                }
                .tag(option)
            }
        }
        .pickerStyle(.inline)
    }

    /// How light or dark the app is.
    ///
    /// Each option carries a symbol rather than a preview of the screen. A
    /// preview large enough to read is a second control, and this choice does
    /// not need one.
    private var appearanceChoice: some View {
        Picker("Appearance", selection: $appearance) {
            ForEach(SampleAppearance.allCases) { option in
                Label {
                    Text(option.title)
                } icon: {
                    // The symbol stands for the mode rather than acting, so it
                    // stays neutral. The check mark is the section's one tint.
                    Image(systemName: option.symbol)
                        .foregroundStyle(.textSecondary)
                }
                .tag(option)
            }
        }
        .pickerStyle(.inline)
    }

    /// Which sessions this person hears about before they start.
    private var reminders: some View {
        Section {
            ForEach(Self.reminderKinds, id: \.self) { kind in
                Toggle(kind, isOn: binding(for: kind))
            }
        } header: {
            Text("Reminders")
        } footer: {
            Text(Self.reminderLimit)
        }
    }

    /// Returns whether this person wants a reminder for one kind of session.
    ///
    /// - Parameter kind: The kind of session to remind about, or stop
    ///   reminding about.
    private func binding(for kind: String) -> Binding<Bool> {
        Binding(
            get: { remindedKinds.contains(kind) },
            set: { isOn in
                if isOn {
                    remindedKinds.insert(kind)
                } else {
                    remindedKinds.remove(kind)
                }
            }
        )
    }

    /// What the conference asks of people, and how to reach it.
    ///
    /// The version sits in this section's footer, which is the last thing on
    /// the screen, so no row has to carry it.
    private var about: some View {
        Section {
            ForEach(SampleResource.settings) { resource in
                ResourceRow(resource: resource)
            }
        } header: {
            Text("SwiftLeeds")
        } footer: {
            Text(Self.version)
        }
    }
}
