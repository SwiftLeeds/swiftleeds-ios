//
//  SidebarView.swift
//  SwiftLeeds
//
//  Created by Karim Ebrahem on 26/06/2023.
//

import SwiftUI

struct SidebarView: View {
    var body: some View {
        List {
            NavigationLink(destination: MyConferenceView()) {
                Label("My Conference", systemImage: "person.fill")
            }
            NavigationLink(destination: LocalView()) {
                Label("Local", systemImage: "map.fill")
            }
            NavigationLink(destination: AboutView()) {
                Label("About", systemImage: "info.circle")
            }
        }
        .listStyle(.sidebar)
    }
}
