import AboutUI
import AuthenticationUI
import LocalUI
import ReadabilityModifier
import ScheduleUI
import SettingsUI
import SponsorsUI
import SwiftUI

struct TabsMainView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            ScheduleView()
                .tabItem {
                    Label("Schedule", systemImage: "person.fill")
                }
                .tag(TabItems.conference)

            LocalView()
                .tabItem {
                    Label("Local", systemImage: "map.fill")
                }
                .tag(TabItems.location)

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(TabItems.about)
            SponsorsView()
                .tabItem {
                    Label("Sponsors", systemImage: "sparkles")
                }
                .tag(TabItems.sponsors)

            SettingsView(contactEmail: .conference, appVersion: .current) {
                Section("Account") { AccountView() }
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(TabItems.settings)
        }
    }
}
