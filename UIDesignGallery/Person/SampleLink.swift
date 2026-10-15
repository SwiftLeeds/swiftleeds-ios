/// A link to a person's page on another platform, made up for the gallery.
///
/// Every field is display text rather than a domain value, for the reason
/// `SampleSession` gives. The symbols are stand-ins, because SF Symbols has no
/// glyphs for brands.
struct SampleLink: Identifiable, Equatable, Hashable, Sendable {
    /// Tells one sample link from another.
    var id: String { platform }

    /// What the platform is called.
    let platform: String

    /// The name of the SF Symbol that stands in for the platform's mark.
    let symbol: String

    /// How the person is found there: a handle, or the domain for a website.
    let handle: String

    /// This link as a resource row opens it.
    var resource: SampleResource {
        SampleResource(
            id: platform,
            title: platform,
            detail: handle,
            symbol: symbol,
            destination: .page,
        )
    }
}

extension SampleLink {
    /// A person's own website.
    ///
    /// - Parameter domain: The website's domain.
    static func website(_ domain: String) -> SampleLink {
        SampleLink(platform: "Website", symbol: "globe", handle: domain)
    }

    /// A person's page on GitHub.
    ///
    /// - Parameter handle: The handle, with its leading at sign.
    static func gitHub(_ handle: String) -> SampleLink {
        SampleLink(
            platform: "GitHub",
            symbol: "chevron.left.forwardslash.chevron.right",
            handle: handle,
        )
    }

    /// A person's page on Mastodon.
    ///
    /// - Parameter handle: The handle, with its server.
    static func mastodon(_ handle: String) -> SampleLink {
        SampleLink(platform: "Mastodon", symbol: "at", handle: handle)
    }

    /// A person's page on LinkedIn.
    ///
    /// - Parameter handle: The path of the person's page.
    static func linkedIn(_ handle: String) -> SampleLink {
        SampleLink(platform: "LinkedIn", symbol: "link", handle: handle)
    }

    /// A person's page on X.
    ///
    /// - Parameter handle: The handle, with its leading at sign.
    static func x(_ handle: String) -> SampleLink {
        SampleLink(platform: "X", symbol: "at", handle: handle)
    }
}
