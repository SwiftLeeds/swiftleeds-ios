import Foundation

// MARK: - Presentation
struct Presentation: Codable, Identifiable {
    let id: UUID
    let title: String
    let synopsis: String
    let speakers: [Speaker]
    let image: String?
    let slidoURL: String?
    let videoURL: String?
}

// MARK: - Static Data
extension Presentation {
    static let donnyWalls = Presentation(
        id: UUID(),
        title: "Building (and testing) custom property wrappers for SwiftUI",
        synopsis: "In this talk, you will learn everything you need to know about using DynamicProperty to build custom property wrappers that integrate with SwiftUI’s view lifecycle and environment beautifully. And more importantly, you will learn how you can write unit tests for your custom property wrappers as well.",
        speakers: [
            Speaker(
                id: UUID(),
                name: "Donny Wals",
                biography: "I'm a curious, passionate iOS Developer from The Netherlands who loves learning and sharing knowledge.",
                profileImage: "https://swiftleeds-speakers.s3.eu-west-2.amazonaws.com/jOaeQ1Og_400x400.jpeg-AEAB9C2A-9572-4E6A-A63E-C3534EE5C321",
                organisation: "DonnyWals.com",
                twitter: "donnywals"
            )
        ],
        image: nil,
        slidoURL: "https://app.sli.do/event/2x7itwrn",
        videoURL: nil
    )

    static let skyBet = Presentation(
        id: UUID(),
        title: "UI automation with XCUItest",
        synopsis: "In this duo talk with Poornima and Sanaa, we'll be exploring how to create the most efficient UI automation using Apple's UI automation frameworks. We'll be covering:\r\n\r\n- What is UI automation testing\r\n- Setting up the framework\r\n- BDD\r\n- Base Class\r\n- Page Object Model\r\n- Data mocking\r\n- Execution: Test Plans/test schemes\r\n- Test Results: Reporting\r\n- Debugging - breakpoints, prints, etc\r\n- CI\r\n- Pros and cons",
        speakers: [
            Speaker(
                id: UUID(),
                name: "Poornima Suraj",
                biography: "16 years of experience in IT with more than 14 years working exclusively on Automation testing.",
                profileImage: "https://swiftleeds-speakers.s3.eu-west-2.amazonaws.com/4769-0o0o0-YroTPVoSrXCZvVwZXEvMUt.png-0DCB39D9-EA7C-4DCA-B4B2-B4712D2A8FCE",
                organisation: "Sky Betting & Gaming",
                twitter: nil
            ),
            Speaker(
                id: UUID(),
                name: "Sanaa Shahzadi",
                biography: "Currently, an iOS Engineer at Sky Betting and Gaming previously worked as a Software Engineer in Test (SEiT).",
                profileImage: "https://swiftleeds-speakers.s3.eu-west-2.amazonaws.com/5b00-0o0o0-nwCWuRFWhXd8QZVQBSB5G2.jpeg-3A19F66F-6A15-44E7-810E-EDF37463B537",
                organisation: "Sky Betting & Gaming",
                twitter: "SanaaShahzadi"
            )
        ],
        image: nil,
        slidoURL: nil,
        videoURL: "https://www.youtube.com/watch?v=x4ZAh-iNQO8&t=2s"
    )
}
