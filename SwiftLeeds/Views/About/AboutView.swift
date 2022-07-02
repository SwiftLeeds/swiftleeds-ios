//
//  AboutView.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 25/06/2022.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        SwiftLeedsContainer {
            ScrollView {
                content
            }
        }
    }

    private var content: some View {
        SponsorGridView()
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
