import SwiftUI
import UIDesign

/// A view that holds what a person can change about the app.
///
/// It is a root: its rows are the parts of Settings, and each opens its own
/// screen. The settings themselves live on those screens.
struct SettingsScreen: View {
    /// The person this screen's account section names.
    let attendee: SampleAttendee

    /// The icon this person gives the app.
    ///
    /// It lives here rather than on the Appearance screen, because the row
    /// that opens that screen shows the answer.
    @State private var icon: SampleAppIcon = .classic

    /// Whether the app may notify this person at all.
    ///
    /// It lives here for the same reason the icon does.
    @State private var allowsNotifications = true

    var body: some View {
        List {
            account
            categories
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .navigationDestination(for: SettingsCategory.self) { category in
            screen(for: category)
        }
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

    /// The parts of Settings, each on a row that opens its own screen.
    ///
    /// A row carries its category's icon, and the icon reappears at the top of
    /// the screen it opens. Four tinted icons in one group depart from one
    /// tint per region: that rule came from toolbars and sheets, and a settings
    /// root is a list of identities, as Apple's own is.
    private var categories: some View {
        Section {
            ForEach(SettingsCategory.allCases, id: \.self) { category in
                NavigationLink(value: category) {
                    row(for: category)
                }
            }
        }
    }

    /// Returns one category's row: its icon, its name, and its answer where it
    /// has one.
    ///
    /// - Parameter category: The part of Settings the row opens.
    private func row(for category: SettingsCategory) -> some View {
        LabeledContent {
            if let answer = answer(for: category) {
                Text(answer)
            }
        } label: {
            Label {
                Text(category.title)
            } icon: {
                CategoryIcon(category: category, placement: .row)
            }
        }
    }

    /// Returns what a category's screen is set to, or `nil` where it has no
    /// single answer worth showing.
    ///
    /// - Parameter category: The part of Settings to sum up.
    private func answer(for category: SettingsCategory) -> String? {
        switch category {
        case .appearance: icon.title
        case .notifications: allowsNotifications ? "On" : "Off"
        case .about: nil
        case .contact: nil
        }
    }

    /// Returns the screen a category's row opens.
    ///
    /// - Parameter category: The part of Settings to open.
    @ViewBuilder
    private func screen(for category: SettingsCategory) -> some View {
        switch category {
        case .appearance:
            AppearanceScreen(icon: $icon)

        case .notifications:
            NotificationsScreen(allowsNotifications: $allowsNotifications)

        case .about:
            AboutScreen()

        case .contact:
            ContactScreen()
        }
    }
}
