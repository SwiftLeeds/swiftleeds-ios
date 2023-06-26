//
//  AboutView.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 25/06/2022.
//

import SwiftUI

struct AboutView: View {

    // TODO: Set these to the correct pages
    let venueURL = URL(string: "https://swiftleeds.co.uk/#venue")
    let codeOfConduct = URL(string: "https://swiftleeds.co.uk/conduct")

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
            FancyHeaderView(
                title: "About",
                foregroundImageName: Assets.Image.swiftLeedsIcon
            )
            VStack(spacing: Padding.cellGap) {
                StackedTileView(primaryText: "About", secondaryText: Strings.aboutSwiftLeeds)

                CommonTileButton(primaryText: "Code of conduct", secondaryText: nil, backgroundStyle: Color.cellBackground) {
                    openURL(url: codeOfConduct)
                }

                CommonTileButton(primaryText: "Venue", secondaryText: nil, backgroundStyle: Color.cellBackground) {
                    openURL(url: venueURL)
                }
            }
            .padding(Padding.screen)
        }
    }

    private func openURL(url: URL?) {
        guard let url = url else {
            return
        }
        UIApplication.shared.open(url)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
