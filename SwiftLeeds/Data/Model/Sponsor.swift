import Foundation

struct Sponsors: Decodable {
    let data: [Sponsor]
}

struct Sponsor: Decodable, Hashable, Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let image: String
    let sponsorLevel: SponsorLevel
    let url: String
    let jobs: [Job]

    static let sample = Sponsor(id: "id", name: "SwiftLeeds", subtitle: "Best Conference", image: "https://swiftleeds-speakers.s3.eu-west-2.amazonaws.com/961E45E2-8667-42F6-895E-4CE5E8B954E2-skybrand.png", sponsorLevel: .platinum, url: "", jobs: [.sample])
}

enum SponsorLevel: String, Decodable {
    case silver
    case platinum
    case gold
}

struct Job: Decodable, Hashable, Identifiable {
    let id: UUID
    let title: String
    let details: String
    let location: String
    let url: String

    static let sample = Job(id: UUID(), title: "Senior iOS Engineer", details: "Bringing all your Swift skills to the fore", location: "Leeds", url: "https://www.swiftleeds.co.uk")
}
