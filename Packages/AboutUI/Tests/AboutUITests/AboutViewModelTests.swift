import AboutFeature
import AboutUI
import Dependencies
import Foundation
import NetworkKit
import Testing

@MainActor
@Suite struct AboutViewModelTests {
    @Test func whenBaseURLIsSet_shouldReturnVenueURLOnThatHost() throws {
        let url = try withBaseURL("https://conference.example") { AboutViewModel().venueURL }

        #expect(url == URL(string: "https://conference.example/#venue"))
    }

    @Test func whenBaseURLIsSet_shouldReturnCodeOfConductURLOnThatHost() throws {
        let url = try withBaseURL("https://conference.example") { AboutViewModel().codeOfConductURL }

        #expect(url == URL(string: "https://conference.example/conduct"))
    }

    @Test func whenLinksAreRead_shouldReturnHTTPSWebAddresses() throws {
        let sut = AboutViewModel()

        let links = [sut.slackURL, sut.youtubeURL, URL(string: sut.reportAProblemLink)]

        for link in links {
            let url = try #require(link)
            let host = try #require(url.host)
            #expect(url.scheme == "https")
            #expect(!host.isEmpty)
        }
    }

    @Test func whenLoadIsCancelled_shouldNotSetError() async {
        let sut = await withDependencies {
            $0.fetchTeam = FetchTeam { () async throws(TeamFetchError) -> [TeamMember] in
                try? await Task.sleep(for: .seconds(10))
                throw .couldNotReachServer
            }
        } operation: {
            let sut = AboutViewModel()
            let load = Task { await sut.loadIfNeeded() }
            load.cancel()
            await load.value
            return sut
        }

        #expect(sut.errorMessage == nil)
    }

    @Test func whenTeamIsLoaded_shouldNotFetchAgain() async throws {
        let fetches = LockIsolated(0)
        let team = [try TeamMember.fixture]

        await withDependencies {
            $0.fetchTeam = FetchTeam { () async throws(TeamFetchError) -> [TeamMember] in
                fetches.withValue { $0 += 1 }
                return team
            }
        } operation: {
            let sut = AboutViewModel()
            await sut.loadIfNeeded()
            await sut.loadIfNeeded()
        }

        #expect(fetches.value == 1)
    }

    @Test func whenLoadFailed_shouldFetchAgainOnNextLoad() async throws {
        let fetches = LockIsolated(0)

        await withDependencies {
            $0.fetchTeam = FetchTeam { () async throws(TeamFetchError) -> [TeamMember] in
                fetches.withValue { $0 += 1 }
                throw .couldNotReachServer
            }
        } operation: {
            let sut = AboutViewModel()
            await sut.loadIfNeeded()
            await sut.loadIfNeeded()
        }

        #expect(fetches.value == 2)
    }

    private func withBaseURL<T>(_ baseURL: String, _ operation: () -> T) throws -> T {
        let configuration = APIConfiguration(baseURL: try #require(URL(string: baseURL)))
        return withDependencies {
            $0.apiConfiguration = configuration
        } operation: {
            operation()
        }
    }
}
