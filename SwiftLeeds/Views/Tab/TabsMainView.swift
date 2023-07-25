//
//  TabsMainView.swift
//  SwiftLeeds
//
//  Created by Karim Ebrahem on 26/06/2023.
//

import SwiftUI
import ReadabilityModifier

struct TabsMainView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            MyConferenceView()
                .tabItem {
                    Label("My Conference", systemImage: "person.fill")
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
        }
    }
}
