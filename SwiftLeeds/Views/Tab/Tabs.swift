//
//  Tabs.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 25/06/2022.
//

import SwiftUI

struct Tabs: View {
    init() {
        UITabBar.appearance().backgroundColor = UIColor(named: "TabBarBackground")
    }

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

struct Tabs_Previews: PreviewProvider {
    static var previews: some View {
        Tabs()
    }
}
