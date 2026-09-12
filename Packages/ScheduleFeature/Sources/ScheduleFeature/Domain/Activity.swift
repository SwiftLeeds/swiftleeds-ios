import Foundation

// MARK: - Activity
public struct Activity: Codable, Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let subtitle: String?
    public let description: String?
    public let image: String?
    public let metadataURL: String?

    public init(
        id: UUID,
        title: String,
        subtitle: String?,
        description: String?,
        image: String?,
        metadataURL: String?
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.image = image
        self.metadataURL = metadataURL
    }
}

// MARK: - Static Data
extension Activity {
    public static let lunch = Activity(
        id: UUID(),
        title: "Lunch 🍕",
        subtitle: "It's time for some well deserved food",
        description: """
            We have partnered with the venue to provide us with handmade food. The venue has an \
            incredible chef who will produce food to cater to everyone. They have access to a \
            stone-baked pizza oven to provide fresh pizza slices and handmade buffet food with a \
            vast selection. Don't forget your handmade brownie or Bakewell slice 😋
            """,
        image: "IMG_6298.jpg-93D1F0E2-6F47-4149-944B-FB824EFB2549",
        metadataURL: ""
    )
}
