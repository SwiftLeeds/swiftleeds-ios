//
//  SidebarView.swift
//  SwiftLeeds
//
//  Created by Karim Ebrahem on 26/06/2023.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        List {
            NavigationLink(destination: MyConferenceView().onAppear {
                appState.selectedTab = .conference
            }) {
                Label("My Conference", systemImage: "person.fill")
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
        }
        .listStyle(.sidebar)
    }
}
