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
    
    //MARK: Mock data for image url
    let foregroundImageUrl = URL(string: "https://cdn.profoto.com/cdn/053149e/contentassets/d39349344d004f9b8963df1551f24bf4/profoto-albert-watson-steve-jobs-pinned-image-original.jpg")!
    let backgroundImageUrl = URL(string: "https://offloadmedia.feverup.com/secretldn.com/wp-content/uploads/2018/02/18151550/aviary-rooftop.jpg")!

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
                imageAssetName: Assets.Image.swiftLeedsIcon,
                backgroundImageAssetName: Assets.Image.playhouseImage
            )
            
            FancyHeaderView(title: "Steve Jobs",
                            foregroundImageURL: foregroundImageUrl ,
                            backgroundImageURL: backgroundImageUrl)
            
            VStack(spacing: Padding.cellGap) {
                StackedTileView(primaryText: "About", secondaryText: Strings.aboutSwiftLeeds)
                CommonTileButton(primaryText: "Code of conduct", secondaryText: nil, backgroundStyle: Color.cellBackground) {
                    openURL(url: codeOfConduct)
                }
                CommonTileButton(primaryText: "Venue", secondaryText: nil, backgroundStyle: Color.cellBackground) {
                    openURL(url: venueURL)
                }
                SponsorGridView()
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
