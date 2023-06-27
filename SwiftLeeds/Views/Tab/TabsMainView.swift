//
//  TabsMainView.swift
//  SwiftLeeds
//
//  Created by Karim Ebrahem on 26/06/2023.
//

import SwiftUI

struct TabsMainView: View {
    var body: some View {
        TabView {
            MyConferenceView()
                .tabItem {
                    Label("My Conference", systemImage: "person.fill")
                }
            
            LocalView()
                .tabItem {
                    Label("Local", systemImage: "map.fill")
                }
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
    }
}
