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
    private let slackURL = URL(string: "https://join.slack.com/t/swiftleedsworkspace/shared_invite/zt-3dex3vb3k-JNYQ~ollX6R619D_tZVfXQ")
    private let youtubeURL = URL(string: "https://www.youtube.com/@swiftleeds")

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

                CommonTileButton(icon: "exclamationmark.triangle.fill", primaryText: "Report a problem", accessibilityHint: "Opens a web view to allow a problem to be reported", backgroundStyle: Color.cellBackground) {
                    isReportAProblemShown = true
                }

                CommonTileButton(icon: "doc.text.fill", primaryText: "Code of conduct", accessibilityHint: "Opens a web page showing our code of conduct", backgroundStyle: Color.cellBackground) {
                    openURL(url: codeOfConductURL)
                }
                
                CommonTileButton(icon: "location.fill", primaryText: "Venue", accessibilityHint: "Opens a web page showing our venue information", backgroundStyle: Color.cellBackground) {
                    openURL(url: venueURL)
                }
                
                CommonTileButton(icon: "message.fill", primaryText: "Join our Slack", accessibilityHint: "Opens an invite link to join the SwiftLeeds Slack workspace", backgroundStyle: Color.cellBackground) {
                    openURL(url: slackURL)
                }
                
                CommonTileButton(icon: "play.rectangle.fill", primaryText: "YouTube Channel", accessibilityHint: "Opens the SwiftLeeds YouTube channel", backgroundStyle: Color.cellBackground) {
                    openURL(url: youtubeURL)
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
