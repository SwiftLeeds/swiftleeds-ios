import AboutUI
import AuthenticationUI
import LocalUI
import ScheduleUI
import SettingsUI
import SponsorsUI
import SwiftUI

struct SidebarMainView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            switch appState.selectedTab {
            case .conference:
                ScheduleView()
            case .about:
                AboutView()
            case .location:
                LocalView()
            case .sponsors:
                SponsorsView()
            case .settings:
                SettingsView(contactEmail: .conference, appVersion: .current) {
                    Section("Account") { AccountView() }
                }
            }
        }
    }
}
