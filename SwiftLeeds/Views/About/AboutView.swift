//
//  AboutView.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 25/06/2022.
//

import SwiftUI
import ReadabilityModifier

struct AboutView: View {
    @State private var isReportAProblemShown = false

    private let venueURL = URL(string: "https://swiftleeds.co.uk/#venue")
    private let codeOfConductURL = URL(string: "https://swiftleeds.co.uk/conduct")
    private let reportAProblemLink = "https://forms.gle/PJie9aRNAtzQUdUu9"

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

                CommonTileButton(primaryText: "Report a problem", backgroundStyle: Color.cellBackground) {
                    isReportAProblemShown = true
                }

                CommonTileButton(primaryText: "Code of conduct", backgroundStyle: Color.cellBackground) {
                    openURL(url: codeOfConductURL)
                }
                
                CommonTileButton(primaryText: "Venue", backgroundStyle: Color.cellBackground) {
                    openURL(url: venueURL)
                }
            }
            .fitToReadableContentGuide(type: .width)
        }
        .padding(.bottom, Padding.cellGap)
        .sheet(isPresented: $isReportAProblemShown) {
            WebView(url: reportAProblemLink)
                .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarHidden(true)
    }
    
    private func openURL(url: URL?) {
        guard let url = url else { return }
        UIApplication.shared.open(url)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
