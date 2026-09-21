import AboutFeature
import Dependencies
import Foundation
import NetworkKit
import Testing

@Suite struct TeamMapperTests {
    private let sut = TeamMapper.live

    @Test func whenTeamHasMembers_shouldReturnMembersInTeamOrder() throws {
        let team = TeamDTO(teamMembers: [
            .fixture(name: "Member One", role: "Organizer"),
            .fixture(name: "Member Two", role: nil),
        ])

        let members = try map(team)

        #expect(members.map(\.id) == [TeamMemberID("Member One"), TeamMemberID("Member Two")])
        #expect(members.map(\.name) == ["Member One", "Member Two"])
        #expect(members.map(\.role) == ["Organizer", nil])
    }

    @Test func whenTeamIsEmpty_shouldReturnNoMembers() throws {
        #expect(try map(TeamDTO(teamMembers: [])).isEmpty)
    }

    @Test func whenPhotoIsPath_shouldReturnPhotoURLOnAPIHost() throws {
        let team = TeamDTO(teamMembers: [.fixture(imageURL: "/img/team/member-one.jpg")])

        let member = try #require(try map(team).first)

        #expect(member.photoURL == URL(string: "https://example.com/img/team/member-one.jpg"))
    }

    @Test func whenPhotoIsAbsoluteURL_shouldReturnSameURL() throws {
        let team = TeamDTO(teamMembers: [.fixture(imageURL: "https://cdn.example.org/member-one.jpg")])

        let member = try #require(try map(team).first)

        #expect(member.photoURL == URL(string: "https://cdn.example.org/member-one.jpg"))
    }

    @Test func whenMemberHasEveryLink_shouldReturnLinksInLinkedInTwitterSlackOrder() throws {
        let team = TeamDTO(teamMembers: [
            .fixture(
                linkedin: "https://linkedin.example.com/member-one",
                twitter: "https://twitter.example.com/member-one",
                slack: "https://slack.example.com/member-one"
            ),
        ])

        let linkedIn = try #require(URL(string: "https://linkedin.example.com/member-one"))
        let twitter = try #require(URL(string: "https://twitter.example.com/member-one"))
        let slack = try #require(URL(string: "https://slack.example.com/member-one"))

        let member = try #require(try map(team).first)

        #expect(member.links == [.linkedIn(linkedIn), .twitter(twitter), .slack(slack)])
    }

    @Test func whenMemberHasNoLinks_shouldReturnNoLinks() throws {
        let team = TeamDTO(teamMembers: [.fixture(linkedin: nil, twitter: nil, slack: nil)])

        let member = try #require(try map(team).first)

        #expect(member.links.isEmpty)
    }

    // MARK: - Refusals

    @Test(arguments: [
        TeamDTO.MemberDTO.CodingKeys.linkedin,
        TeamDTO.MemberDTO.CodingKeys.twitter,
        TeamDTO.MemberDTO.CodingKeys.slack,
    ])
    func whenLinkIsEmpty_shouldThrowErrorWithMemberFieldAndValue(field: TeamDTO.MemberDTO.CodingKeys) throws {
        let member = TeamDTO.MemberDTO.fixture(
            name: "Member One",
            linkedin: field == .linkedin ? "" : nil,
            twitter: field == .twitter ? "" : nil,
            slack: field == .slack ? "" : nil
        )

        let error = try #require(throws: TeamMapper.MappingError.self) {
            try map(TeamDTO(teamMembers: [member]))
        }

        #expect(error == TeamMapper.MappingError(member: TeamMemberID("Member One"), field: field, value: ""))
    }

    @Test(arguments: ["twitter.example.com/member-one", "tel:01130000000", "https://"])
    func whenLinkIsNotWebAddress_shouldThrowErrorWithMemberFieldAndValue(link: String) throws {
        let team = TeamDTO(teamMembers: [.fixture(name: "Member One", twitter: link)])

        let error = try #require(throws: TeamMapper.MappingError.self) {
            try map(team)
        }

        #expect(error == TeamMapper.MappingError(member: TeamMemberID("Member One"), field: .twitter, value: link))
    }

    @Test func whenOneMemberIsInvalid_shouldThrowForWholeTeam() throws {
        let team = TeamDTO(teamMembers: [.fixture(name: "Member One"), .fixture(name: "Member Two", slack: "")])

        #expect(throws: TeamMapper.MappingError.self) {
            try map(team)
        }
    }

    @Test func whenPhotoIsEmpty_shouldThrowErrorWithMemberFieldAndValue() throws {
        let team = TeamDTO(teamMembers: [.fixture(name: "Member One", imageURL: "")])

        let error = try #require(throws: TeamMapper.MappingError.self) {
            try map(team)
        }

        #expect(error == TeamMapper.MappingError(member: TeamMemberID("Member One"), field: .imageURL, value: ""))
    }

    private func map(_ team: TeamDTO) throws -> [TeamMember] {
        let configuration = APIConfiguration(baseURL: try baseURL)
        return try withDependencies {
            $0.apiConfiguration = configuration
        } operation: {
            try sut.map(team)
        }
    }

    private var baseURL: URL {
        get throws { try #require(URL(string: "https://example.com")) }
    }
}
