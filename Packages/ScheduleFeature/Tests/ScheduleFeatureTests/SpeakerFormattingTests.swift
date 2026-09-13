import Foundation
import ScheduleFeature
import Testing

@Suite struct SpeakerFormattingTests {
    @Test func whenTwoSpeakersShareAnOrganisation_shouldNameItOnce() {
        let speakers = [
            Speaker.fixture(name: "Alex", organisation: "Leeds Software Co"),
            Speaker.fixture(name: "Sam", organisation: "Leeds Software Co"),
        ]

        #expect(speakers.joinedOrganisations == "Leeds Software Co")
    }

    // Five, because a Set orders by hash: with fewer, a broken build passes often enough
    // to look green. One order in 120 matches by luck.
    @Test func whenSpeakersDiffer_shouldKeepTheSpeakerOrder() {
        let organisations = ["Ada Software", "Bo Software", "Cy Software", "Di Software", "Eli Software"]
        let speakers = organisations.map { Speaker.fixture(name: "Speaker", organisation: $0) }

        // The formatter joins for the reader's locale, so ask it rather than pin its wording.
        let inSpeakerOrder = ListFormatter.localizedString(byJoining: organisations)
        #expect(speakers.joinedOrganisations == inSpeakerOrder)
    }
}

private extension Speaker {
    static func fixture(name: String, organisation: String) -> Speaker {
        Speaker(
            id: UUID(),
            name: name,
            biography: "",
            profileImage: "",
            organisation: organisation,
            twitter: nil
        )
    }
}
