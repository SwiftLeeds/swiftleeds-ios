import Settings
import SwiftUI
import ReadabilityModifier

struct TabsMainView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            MyConferenceView()
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
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(TabItems.settings)
        }
    }
}
