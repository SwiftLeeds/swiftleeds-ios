import SwiftUI
import UIDesign

/// A view that holds what the app tells a person about before it happens.
///
/// The master switch is the last row of the introduction's card. The kinds of
/// session it covers are drawn only while it is on: a setting that does not
/// apply is absent, not disabled.
struct NotificationsScreen: View {
    /// The kinds of session a reminder can cover.
    ///
    /// These are display text, for the reason `SampleSession` gives.
    private static let kinds = ["Talks", "Lightning talks", "Workshops"]

    /// What iOS does once a person saves more sessions than it can hold.
    private static let limit = """
        iOS keeps up to 64 reminders waiting. Sessions past that get none.
        """

    /// Whether the app may notify this person at all.
    @Binding var allowsNotifications: Bool

    /// The kinds of session this person wants a reminder for.
    @State private var remindedKinds: Set<String> = ["Talks"]

    /// Whether this person has asked for less movement on screen.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        List {
            Section {
                CategoryIntroduction(category: .notifications)

                Toggle("Allow notifications", isOn: allowing)
            }

            if allowsNotifications {
                kinds
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(SettingsCategory.notifications.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    /// The master switch's binding, which animates the kinds in and out.
    ///
    /// The animation is dropped when this person has asked for less motion,
    /// so the section then appears in place.
    private var allowing: Binding<Bool> {
        Binding(
            get: { allowsNotifications },
            set: { isOn in
                withAnimation(reduceMotion ? nil : .default) {
                    allowsNotifications = isOn
                }
            }
        )
    }

    /// Which sessions this person hears about before they start.
    private var kinds: some View {
        Section {
            ForEach(Self.kinds, id: \.self) { kind in
                Toggle(kind, isOn: binding(for: kind))
            }
        } header: {
            Text("Remind me about")
        } footer: {
            Text(Self.limit)
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
}
