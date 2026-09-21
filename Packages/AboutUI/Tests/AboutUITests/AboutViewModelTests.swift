import AboutFeature
import AboutUI
import Dependencies
import Foundation
import NetworkKit
import Testing

@MainActor
@Suite struct AboutViewModelTests {
    @Test func whenBaseURLIsSet_shouldReturnVenueURLOnThatHost() throws {
        let sut = AboutViewModel()

        let url = try withAPI { sut.venueURL }

        #expect(url == URL(string: "https://example.com/#venue"))
    }

    @Test func whenBaseURLIsSet_shouldReturnCodeOfConductURLOnThatHost() throws {
        let sut = AboutViewModel()

        let url = try withAPI { sut.codeOfConductURL }

        #expect(url == URL(string: "https://example.com/conduct"))
    }

    @Test func whenLinksAreRead_shouldReturnHTTPSWebAddresses() throws {
        let sut = AboutViewModel()

        let links = [sut.slackURL, sut.youtubeURL, URL(string: sut.reportAProblemLink)]

        for link in links {
            let url = try #require(link)
            #expect(url.scheme == "https")
            #expect(url.host?.isEmpty == false)
        }
    }

    @Test func whenLoadIsCancelled_shouldNotSetError() async {
        let sut = AboutViewModel()

        await withDependencies {
            $0.fetchTeam = FetchTeam { () async throws(TeamFetchError) -> [TeamMember] in
                try? await Task.sleep(for: .seconds(10))
                throw .couldNotReachServer
            }
        } operation: {
            let load = Task { await sut.loadIfNeeded() }
            load.cancel()
            await load.value
        }

        #expect(sut.errorMessage == nil)
    }

    private func withAPI<T>(_ operation: () -> T) throws -> T {
        let configuration = APIConfiguration(baseURL: try #require(URL(string: "https://example.com")))
        return withDependencies {
            $0.apiConfiguration = configuration
        } operation: {
            operation()
        }
    }
}
