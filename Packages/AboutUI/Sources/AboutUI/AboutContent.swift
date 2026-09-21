struct AboutContent: Equatable, Hashable, Sendable {
    struct Links: Equatable, Hashable, Sendable {
        // Paths on the API host.
        let venue: String
        let codeOfConduct: String

        let reportAProblem: String
        let slack: String
        let youtube: String
    }

    let links: Links
    let truncatedAboutText: String
    let fullAboutText: String
}

extension AboutContent {
    static let swiftLeeds = AboutContent(
        links: Links(
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
        """,
        fullAboutText: """
        Adam Rush founded SwiftLeeds in 2019, born from over ten years of experience attending \
        conferences. The inspiration was bringing a modern, inclusive conference in the North of the UK \
        to be more accessible for all.

        SwiftLeeds is now run with over ten community volunteers building the website, iOS applications \
        and making sure we cover all the bases on the day. SwiftLeeds is entirely non-profit, and the \
        funds make sure we can deliver the best experience possible.

        In-person conferences are the best way to meet like-minded people who enjoy building apps with \
        Swift. You can also learn from the best people in the industry and chat about all things Swift.
        """
    )
}
