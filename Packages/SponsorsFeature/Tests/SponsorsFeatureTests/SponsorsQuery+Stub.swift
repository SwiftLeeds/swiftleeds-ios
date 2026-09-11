import SponsorsFeature

extension SponsorsQuery {
    static func returning(_ sponsors: [Sponsor]) -> SponsorsQuery {
        SponsorsQuery { sponsors }
    }

    static func failing(with error: SponsorFetchError) -> SponsorsQuery {
        SponsorsQuery { () async throws(SponsorFetchError) -> [Sponsor] in throw error }
    }
}
