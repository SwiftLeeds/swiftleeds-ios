import AboutUI
import LocalUI
import ScheduleUI
import SettingsUI
import SponsorsUI
import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        List {
            NavigationLink(destination: ScheduleView().onAppear {
                appState.selectedTab = .conference
            }) {
                Label("Schedule", systemImage: "person.fill")
            }
            NavigationLink(destination: LocalView().onAppear {
                appState.selectedTab = .location
            }) {
                Label("Local", systemImage: "map.fill")
            }
            NavigationLink(destination: AboutView().onAppear {
                appState.selectedTab = .about
            }) {
                Label("About", systemImage: "info.circle")
            }
            NavigationLink(destination: SponsorsView().onAppear {
                appState.selectedTab = .sponsors
            }) {
                Label("Sponsors", systemImage: "sparkles")
            }

            NavigationLink(destination: SettingsView(contactEmail: .conference, appVersion: .current).onAppear {
                appState.selectedTab = .settings
            }) {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .listStyle(.sidebar)
    }
}
