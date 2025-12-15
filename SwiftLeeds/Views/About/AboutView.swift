import DesignKit
import CachedAsyncImage
import ReadabilityModifier
import SharedAssets
import SharedViews
import SwiftUI

struct AboutView: View {
    @StateObject private var viewModel = AboutViewModel()
    @State private var isReportAProblemShown = false
    @State private var isFullAboutShown = false
    
    private var gridColumns: [GridItem] {
        #if os(iOS)
        let columnCount = UIDevice.current.userInterfaceIdiom == .pad ? 4 : 3
        #else
        let columnCount = 3
        #endif
        return Array(repeating: GridItem(.flexible(), spacing: Padding.cellGap), count: columnCount)
    }
    
    private var teamGridColumns: [GridItem] {
        #if os(iOS)
        let columnCount = UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2
        #else
        let columnCount = 2
        #endif
        return Array(repeating: GridItem(.flexible(), spacing: Padding.cellGap), count: columnCount)
    }

    var body: some View {
        ScrollView {
            content
        }
        .background(Color.background, ignoresSafeAreaEdges: .all)
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
                        Text(.init(viewModel.truncatedAboutText))
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
                .accessibilityLabel("About SwiftLeeds. \(viewModel.truncatedAboutText). Tap More for full details.")

                LazyVGrid(columns: gridColumns, spacing: Padding.cellGap) {
                    CompactActionItem(
                        icon: "exclamationmark.triangle.fill",
                        title: "Report a\nProblem",
                        accessibilityHint: "Opens a web view to allow a problem to be reported",
                        action: { isReportAProblemShown = true }
                    )
                    
                    CompactActionItem(
                        icon: "doc.text.fill",
                        title: "Code of\nConduct",
                        accessibilityHint: "Opens a web page showing our code of conduct",
                        action: { openURL(url: viewModel.codeOfConductURL) }
                    )
                    
                    CompactActionItem(
                        icon: "location.fill",
                        title: "Venue\nInfo",
                        accessibilityHint: "Opens a web page showing our venue information",
                        action: { openURL(url: viewModel.venueURL) }
                    )
                    
                    CompactActionItem(
                        icon: "message.fill",
                        title: "Join our\nSlack",
                        accessibilityHint: "Opens an invite link to join the SwiftLeeds Slack workspace",
                        action: { openURL(url: viewModel.slackURL) }
                    )
                    
                    CompactActionItem(
                        icon: "play.rectangle.fill",
                        title: "YouTube\nChannel",
                        accessibilityHint: "Opens the SwiftLeeds YouTube channel",
                        action: { openURL(url: viewModel.youtubeURL) }
                    )
                }
                .padding(.vertical, 8)
                
                VStack(alignment: .leading, spacing: Padding.stackGap) {
                    Text("Meet the Team")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    Text("Connect with our amazing volunteers who make SwiftLeeds possible")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .padding(Padding.cell)
                .background(
                    Color.cellBackground,
                    in: RoundedRectangle(cornerRadius: Constants.cellRadius)
                )
                
                LazyVGrid(columns: teamGridColumns, spacing: Padding.cellGap) {
                    ForEach(viewModel.teamMembers) { member in
                        TeamMemberView(member: member)
                    }
                }
                .padding(.vertical, 8)
            }
            .fitToReadableContentGuide(type: .width)
        }
        .padding(.bottom, Padding.cellGap)
        .sheet(isPresented: $isReportAProblemShown) {
            WebView(url: viewModel.reportAProblemLink)
                .ignoresSafeArea(edges: .bottom)
        }
        .sheet(isPresented: $isFullAboutShown) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: Padding.cellGap) {
                        Text(aboutSwiftLeeds)
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

    private let aboutSwiftLeeds = """
    Adam Rush founded SwiftLeeds in 2019, born from over ten years of experience attending conferences. The inspiration was bringing a modern, inclusive conference in the North of the UK to be more accessible for all.
    
    SwiftLeeds is now run with over ten community volunteers building the website, iOS applications and making sure we cover all the bases on the day. SwiftLeeds is entirely non-profit, and the funds make sure we can deliver the best experience possible.
    
    In-person conferences are the best way to meet like-minded people who enjoy building apps with Swift. You can also learn from the best people in the industry and chat about all things Swift.
    """
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
            .preferredColorScheme(.dark)
    }
}
