import SwiftUI
import UIDesign

/// A view that holds what a person can change about how the app looks.
///
/// Light and dark follow the system, so the icon is the one choice here. It
/// pushes a screen to choose on, and the row carries the current answer.
struct AppearanceScreen: View {
    /// The icon this person gives the app.
    @Binding var icon: SampleAppIcon

    var body: some View {
        List {
            Section {
                CategoryIntroduction(category: .appearance)
            }

            Section {
                Picker("App icon", selection: $icon) {
                    ForEach(SampleAppIcon.allCases) { option in
                        ReflowingStack {
                            MockAppIcon(icon: option)

                            Text(option.title)
                        }
                        .tag(option)
                    }
                }
                .pickerStyle(.navigationLink)
            } footer: {
                Text("Your Home Screen shows the icon you choose.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(SettingsCategory.appearance.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
