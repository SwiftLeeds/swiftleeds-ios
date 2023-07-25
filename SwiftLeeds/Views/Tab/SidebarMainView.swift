//
//  SidebarMainView.swift
//  SwiftLeeds
//
//  Created by Karim Ebrahem on 26/06/2023.
//

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
            }
        }

    }
}
