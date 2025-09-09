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
    @State private var isFullAboutShown = false

    private let venueURL = URL(string: "https://swiftleeds.co.uk/#venue")
    private let codeOfConductURL = URL(string: "https://swiftleeds.co.uk/conduct")
    private let reportAProblemLink = "https://forms.gle/PJie9aRNAtzQUdUu9"
    private let slackURL = URL(string: "https://join.slack.com/t/swiftleedsworkspace/shared_invite/zt-3dex3vb3k-JNYQ~ollX6R619D_tZVfXQ")
    private let youtubeURL = URL(string: "https://www.youtube.com/@swiftleeds")
    
    private let truncatedAboutText = """
    Adam Rush founded SwiftLeeds in 2019, born from over ten years of experience attending conferences. The inspiration was bringing a modern, inclusive conference in the North of the UK to be more accessible for all.
    
    SwiftLeeds is now run with over ten community volunteers building the website, iOS applications...
    """
    
    private var gridColumns: [GridItem] {
        #if os(iOS)
        let columnCount = UIDevice.current.userInterfaceIdiom == .pad ? 4 : 3
        #else
        let columnCount = 3
        #endif
        return Array(repeating: GridItem(.flexible(), spacing: Padding.cellGap), count: columnCount)
    }

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
                VStack(alignment: .leading, spacing: Padding.stackGap) {
                    Text("About")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(.init(truncatedAboutText))
                            .font(.subheadline.weight(.regular))
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Spacer()
                            Button("More") {
                                isFullAboutShown = true
                            }
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.accentColor)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(Padding.cell)
                .background(
                    Color.cellBackground,
                    in: RoundedRectangle(cornerRadius: Constants.cellRadius)
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("About SwiftLeeds. \(truncatedAboutText). Tap More for full details.")

                LazyVGrid(columns: gridColumns, spacing: Padding.cellGap) {
                    CompactActionItem(
                        icon: "exclamationmark.triangle.fill",
                        title: "Report\nProblem",
                        accessibilityHint: "Opens a web view to allow a problem to be reported",
                        action: { isReportAProblemShown = true }
                    )
                    
                    CompactActionItem(
                        icon: "doc.text.fill",
                        title: "Code of\nConduct",
                        accessibilityHint: "Opens a web page showing our code of conduct",
                        action: { openURL(url: codeOfConductURL) }
                    )
                    
                    CompactActionItem(
                        icon: "location.fill",
                        title: "Venue\nInfo",
                        accessibilityHint: "Opens a web page showing our venue information",
                        action: { openURL(url: venueURL) }
                    )
                    
                    CompactActionItem(
                        icon: "message.fill",
                        title: "Join our\nSlack",
                        accessibilityHint: "Opens an invite link to join the SwiftLeeds Slack workspace",
                        action: { openURL(url: slackURL) }
                    )
                    
                    CompactActionItem(
                        icon: "play.rectangle.fill",
                        title: "YouTube\nChannel",
                        accessibilityHint: "Opens the SwiftLeeds YouTube channel",
                        action: { openURL(url: youtubeURL) }
                    )
                }
                .padding(.vertical, 8)
            }
            .fitToReadableContentGuide(type: .width)
        }
        .padding(.bottom, Padding.cellGap)
        .sheet(isPresented: $isReportAProblemShown) {
            WebView(url: reportAProblemLink)
                .ignoresSafeArea(edges: .bottom)
        }
        .sheet(isPresented: $isFullAboutShown) {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: Padding.cellGap) {
                        Text(.init(Strings.aboutSwiftLeeds))
                            .font(.body)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .padding(Padding.cell)
                            .background(
                                Color.cellBackground,
                                in: RoundedRectangle(cornerRadius: Constants.cellRadius)
                            )
                    }
                    .padding(Padding.screen)
                }
                .navigationTitle("About")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            isFullAboutShown = false
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func openURL(url: URL?) {
        guard let url = url else { return }
        UIApplication.shared.open(url)
    }
}

struct CompactActionItem: View {
    let icon: String
    let title: String
    let accessibilityHint: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.accentColor)
                    .frame(height: 32)
                
                Text(title)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                Color.cellBackground,
                in: RoundedRectangle(cornerRadius: Constants.cellRadius)
            )
        }
        .buttonStyle(SquishyButtonStyle())
        .accessibilityHint(accessibilityHint)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
