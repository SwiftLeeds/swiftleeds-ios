import Settings
import SwiftUI

struct SidebarMainView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            switch appState.selectedTab {
            case .conference:
                MyConferenceView()
            case .about:
                AboutView()
            case .location:
                LocalView()
            case .sponsors:
                SponsorsView()
            case .settings:
                SettingsView()
            }
        }

    }
}
