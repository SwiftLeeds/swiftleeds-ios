//
//  SidebarMainView.swift
//  SwiftLeeds
//
//  Created by Karim Ebrahem on 26/06/2023.
//

import SwiftUI

struct SidebarMainView: View {
    var body: some View {
        NavigationView {
            SidebarView()
            MyConferenceView()
        }
    }
}
