import Foundation

/// The sponsor list as the backend sends it. Data only.
package struct SponsorListDTO: Decodable {
    package let data: [SponsorDTO]

    package init(data: [SponsorDTO]) {
        self.data = data
    }

    package struct SponsorDTO: Decodable {
        /// Declared rather than synthesised, so an error can name a field as data
        /// and a property added without its key fails to compile.
        package enum CodingKeys: String, CodingKey {
            case id
            case name
            case subtitle
            case image
            case sponsorLevel
            case url
            case jobs
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
            jobs: [JobDTO]
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
}
