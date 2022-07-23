//
//  SpeakerView.swift
//  SwiftLeeds
//
//  Created by LUCKY AGARWAL on 23/07/22.
//

import SwiftUI

struct SpeakerView: View {
    var body: some View {
        SwiftLeedsContainer {
            ScrollView {
                content
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    private var content: some View {
        VStack(spacing: Padding.stackGap) {
            HeaderView(
                title: "Speaker Name",
                imageAssetName: Assets.Image.swiftLeedsIcon,
                backgroundImageAssetName: Assets.Image.playhouseImage
            )
            VStack(spacing: Padding.screen){
                StackedTileView(primaryText: "The Talk",
                                secondaryText: "Stuff about the talk this could be long...",
                                secondaryColor: Color.primary
                )
                CommonTileButton(
                    primaryText: "Ask Questions Now",
                    secondaryText: nil,
                    primaryColor: .white,
                    secondaryColor: .white.opacity(0.8),
                    backgroundStyle: LinearGradient(gradient: Gradient(colors:[.buyTicketGradientStart, .buyTicketGradientEnd]) ,startPoint: .leading, endPoint: .trailing),
                    onTap: {}
                )
                StackedTileView(primaryText: "About",
                                secondaryText: "This speaker is a speaker that can speak words about things to with swift is it about servers? apps? the language? who knows, but there's plenty of space for information about them here.",
                                secondaryColor: Color.primary
                )
                CommonTileView(primaryText: "Twitter",
                               secondaryText: "@somelongtwitter",
                               secondaryColor: Color.primary
                )
            }
            .padding(Padding.screen)
        }
    }
}

struct SpeakerView_Previews: PreviewProvider {
    static var previews: some View {
        SpeakerView()
    }
}
