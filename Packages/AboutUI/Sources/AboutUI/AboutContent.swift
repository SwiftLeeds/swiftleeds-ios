// The links and short text on the About screen.
struct AboutContent {
    struct URLs {
        // Paths on the API host.
        let venue: String
        let codeOfConduct: String

        let reportAProblem: String
        let slack: String
        let youtube: String
    }

    let urls: URLs
    let truncatedAboutText: String
}

extension AboutContent {
    // KotlinLeeds shows this too, which is a known gap.
    static let swiftLeeds = AboutContent(
        urls: URLs(
            venue: "/#venue",
            codeOfConduct: "/conduct",
            reportAProblem: "https://forms.gle/PJie9aRNAtzQUdUu9",
            slack: "https://join.slack.com/t/swiftleedsworkspace/shared_invite/zt-3dex3vb3k-JNYQ~ollX6R619D_tZVfXQ",
            youtube: "https://www.youtube.com/@swiftleeds"
        ),
        truncatedAboutText: """
        Adam Rush founded SwiftLeeds in 2019, born from over ten years of experience attending \
        conferences. The inspiration was bringing a modern, inclusive conference in the North of \
        the UK to be more accessible for all.

        SwiftLeeds is now run with over ten community volunteers building the website, iOS \
        applications...
        """
    )
}
