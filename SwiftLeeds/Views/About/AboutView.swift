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
        .edgesIgnoringSafeArea(.top)
    }

    private var content: some View {
        VStack(spacing: Padding.cellGap) {
            HeaderView(
                title: "Swift Leeds",
                // Placeholders
                imageURL: URL(string: "https://cdn-az.allevents.in/events5/banners/458482c4fc7489448aa3d77f6e2cd5d0553fa5edd7178dbf18cf986d2172eaf2-rimg-w1200-h675-gmir.jpg?v=1655230338"),
                backgroundURL: URL(string:"https://www.nycgo.com/images/itineraries/42961/soc_fb_dumbo_spots__facebook.jpg")
            )
            SponsorGridView()
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
