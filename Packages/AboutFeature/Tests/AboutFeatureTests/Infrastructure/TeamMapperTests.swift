import AboutFeature
import Dependencies
import Foundation
import NetworkKit
import Testing

@Suite struct TeamMapperTests {
    private let sut = TeamMapper.live

    @Test func whenTeamHasMembers_shouldReturnMembersInTeamOrder() throws {
        let team = TeamDTO(teamMembers: [
            .fixture(name: "Adam Rush", role: "Founder and Host"),
            .fixture(name: "Kannan Prasad", role: nil),
        ])

        let members = try map(team)

        #expect(members.map(\.id) == [TeamMemberID("Adam Rush"), TeamMemberID("Kannan Prasad")])
        #expect(members.map(\.name) == ["Adam Rush", "Kannan Prasad"])
        #expect(members.map(\.role) == ["Founder and Host", nil])
    }

    @Test func whenTeamIsEmpty_shouldReturnNoMembers() throws {
        #expect(try map(TeamDTO(teamMembers: [])).isEmpty)
    }

    @Test func whenPhotoIsPath_shouldReturnPhotoURLOnAPIHost() throws {
        let team = TeamDTO(teamMembers: [.fixture(imageURL: "/img/team/rush.jpg")])

        let member = try #require(try map(team).first)

        #expect(member.photoURL == URL(string: "https://example.com/img/team/rush.jpg"))
    }

    @Test func whenPhotoIsAbsoluteURL_shouldReturnSameURL() throws {
        let team = TeamDTO(teamMembers: [.fixture(imageURL: "https://cdn.example.org/rush.jpg")])

        let member = try #require(try map(team).first)

        #expect(member.photoURL == URL(string: "https://cdn.example.org/rush.jpg"))
    }

    @Test func whenMemberHasEveryLink_shouldReturnLinksInLinkedInTwitterSlackOrder() throws {
        let team = TeamDTO(teamMembers: [
            .fixture(
                linkedin: "https://www.linkedin.com/in/rush/",
                twitter: "https://twitter.com/rush",
                slack: "https://swiftleeds.slack.com/rush"
            ),
        ])

        let linkedIn = try #require(URL(string: "https://www.linkedin.com/in/rush/"))
        let twitter = try #require(URL(string: "https://twitter.com/rush"))
        let slack = try #require(URL(string: "https://swiftleeds.slack.com/rush"))

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
    func whenLinkIsNotURL_shouldThrowErrorWithMemberFieldAndValue(field: TeamDTO.MemberDTO.CodingKeys) throws {
        let member = TeamDTO.MemberDTO.fixture(
            name: "Adam Rush",
            linkedin: field == .linkedin ? "" : nil,
            twitter: field == .twitter ? "" : nil,
            slack: field == .slack ? "" : nil
        )

        let error = try #require(throws: TeamMapper.MappingError.self) {
            try map(TeamDTO(teamMembers: [member]))
        }

        #expect(error == TeamMapper.MappingError(member: TeamMemberID("Adam Rush"), field: field, value: ""))
    }

    @Test func whenOneMemberIsInvalid_shouldThrowForWholeTeam() throws {
        let team = TeamDTO(teamMembers: [.fixture(name: "Adam Rush"), .fixture(name: "Paul Willis", slack: "")])

        #expect(throws: TeamMapper.MappingError.self) {
            try map(team)
        }
    }

    @Test func whenPhotoIsNotURL_shouldThrowErrorWithMemberFieldAndValue() throws {
        let team = TeamDTO(teamMembers: [.fixture(name: "Adam Rush", imageURL: "")])

        let error = try #require(throws: TeamMapper.MappingError.self) {
            try map(team)
        }

        #expect(error == TeamMapper.MappingError(member: TeamMemberID("Adam Rush"), field: .imageURL, value: ""))
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
