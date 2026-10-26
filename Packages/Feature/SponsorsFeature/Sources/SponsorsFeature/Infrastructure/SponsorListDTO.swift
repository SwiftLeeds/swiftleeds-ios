import Foundation

/// The sponsor list as the backend sends it.
///
/// It carries data only.
package struct SponsorListDTO: Decodable {
    /// One sponsor as the backend sends it.
    package struct SponsorDTO: Decodable {
        package enum CodingKeys: String, CodingKey {
            case id = "id"
            case name = "name"
            case subtitle = "subtitle"
            case image = "image"
            case sponsorLevel = "sponsorLevel"
            case url = "url"
            case jobs = "jobs"
        }

        package let id: String
        package let name: String
        package let subtitle: String
        package let image: String
        package let sponsorLevel: String
        package let url: String
        package let jobs: [JobDTO]

        package init(
            id: String,
            name: String,
            subtitle: String,
            image: String,
            sponsorLevel: String,
            url: String,
            jobs: [JobDTO],
        ) {
            self.id = id
            self.name = name
            self.subtitle = subtitle
            self.image = image
            self.sponsorLevel = sponsorLevel
            self.url = url
            self.jobs = jobs
        }
    }

    /// One job a sponsor advertises, as the backend sends it.
    package struct JobDTO: Decodable {
        package let id: UUID
        package let title: String
        package let details: String
        package let location: String
        package let url: String

        package init(id: UUID, title: String, details: String, location: String, url: String) {
            self.id = id
            self.title = title
            self.details = details
            self.location = location
            self.url = url
        }
    }

    package let data: [SponsorDTO]

    package init(data: [SponsorDTO]) {
        self.data = data
    }
}
