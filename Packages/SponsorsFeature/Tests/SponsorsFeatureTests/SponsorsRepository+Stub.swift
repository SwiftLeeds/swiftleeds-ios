import SponsorsFeature

extension SponsorsRepository {
    static func returning(_ sponsors: Sponsors) -> SponsorsRepository {
        SponsorsRepository { sponsors }
    }

    static func failing(with error: SponsorFetchError) -> SponsorsRepository {
        SponsorsRepository { () async throws(SponsorFetchError) -> Sponsors in throw error }
    }
}
