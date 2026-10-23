import Foundation

// MARK: - Presentation
public struct Presentation: Codable, Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let synopsis: String
    public let speakers: [Speaker]
    public let image: String?
    public let slidoURL: String?
    public let videoURL: String?

    public init(
        id: UUID,
        title: String,
        synopsis: String,
        speakers: [Speaker],
        image: String?,
        slidoURL: String?,
        videoURL: String?,
    ) {
        self.id = id
        self.title = title
        self.synopsis = synopsis
        self.speakers = speakers
        self.image = image
        self.slidoURL = slidoURL
        self.videoURL = videoURL
    }
}

// MARK: - Static Data
extension Presentation {
    /// A made-up talk by one speaker, with a Slido link and no video.
    public static let soloTalk = Presentation(
        id: UUID(),
        title: "Sample Talk Title",
        synopsis: "A made-up synopsis for a talk given by one speaker.",
        speakers: [
            .init(
                id: UUID(),
                name: "Speaker One",
                biography: "A made-up biography for the first speaker.",
                profileImage: "https://images.example.com/speaker-one.png",
                organisation: "Example Organization",
                twitter: "speakerone",
            )
        ],
        image: nil,
        slidoURL: "https://slido.example.com/event/sample",
        videoURL: nil,
    )

    /// A made-up talk by two speakers, with a video and no Slido link.
    public static let duoTalk = Presentation(
        id: UUID(),
        title: "Sample Duo Talk Title",
        synopsis: "A made-up synopsis for a talk given by two speakers.",
        speakers: [
            .init(
                id: UUID(),
                name: "Speaker Two",
                biography: "A made-up biography for the second speaker.",
                profileImage: "https://images.example.com/speaker-two.png",
                organisation: "Example Organization",
                twitter: nil,
            ),
            .init(
                id: UUID(),
                name: "Speaker Three",
                biography: "A made-up biography for the third speaker.",
                profileImage: "https://images.example.com/speaker-three.png",
                organisation: "Example Organization",
                twitter: "speakerthree",
            ),
        ],
        image: nil,
        slidoURL: nil,
        videoURL: "https://video.example.com/watch/sample",
    )
}
