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

    private func withAPI<T>(_ operation: () -> T) throws -> T {
        let configuration = APIConfiguration(baseURL: try #require(URL(string: "https://example.com")))
        return withDependencies {
            $0.apiConfiguration = configuration
        } operation: {
            operation()
        }
    }
}
