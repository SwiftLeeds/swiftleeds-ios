import Dependencies
import DependenciesTestSupport
import Foundation
import NetworkKit
import SettingsUI
import Sharing
import Testing

@MainActor
@Suite struct SettingsViewModelTests {
    @Test func whenIconChangeSucceeds_shouldReturnNewIcon() async throws {
        let sut = try await changingIcon(to: .space, result: .success(()))

        #expect(sut.currentIcon == .space)
    }

    @Test func whenIconChangeSucceeds_shouldStoreNewIcon() async throws {
        _ = try await changingIcon(to: .olympics, result: .success(()))

        @Shared(.selectedAppIcon) var storedIcon
        #expect(storedIcon == .olympics)
    }

    @Test(.dependencies, arguments: [ChangeAppIcon.Error.unsupported, .refused])
    func whenIconChangeFails_shouldShowIconError(error: ChangeAppIcon.Error) async throws {
        let sut = try await changingIcon(to: .space, result: .failure(error))

        #expect(sut.showingIconError)
    }

    @Test(.dependencies, arguments: [ChangeAppIcon.Error.unsupported, .refused])
    func whenIconChangeFails_shouldKeepCurrentIcon(error: ChangeAppIcon.Error) async throws {
        let sut = try await changingIcon(to: .space, result: .failure(error))

        #expect(sut.currentIcon == .generic)
    }

    @Test func whenContactUsIsOpened_shouldOpenMailtoLinkForContactEmail() async throws {
        let sut = try SettingsViewModel(
            contactEmail: ContactEmail("organizers@conference.example"),
            appVersion: .fixture
        )
        let opened = LockIsolated<[URL]>([])

        await withDependencies {
            $0.openURL = recordingOpenURL(into: opened)
        } operation: {
            await sut.openContactUs()
        }

        #expect(opened.value == [URL(string: "mailto:organizers@conference.example")])
    }

    @Test func whenCodeOfConductIsOpened_shouldOpenConductPageOnAPIHost() async throws {
        let configuration = APIConfiguration(baseURL: try #require(URL(string: "https://conference.example")))
        let sut = try SettingsViewModel.fixture
        let opened = LockIsolated<[URL]>([])

        await withDependencies {
            $0.apiConfiguration = configuration
            $0.openURL = recordingOpenURL(into: opened)
        } operation: {
            await sut.openCodeOfConduct()
        }

        #expect(opened.value == [URL(string: "https://conference.example/conduct")])
    }

    private func changingIcon(
        to icon: AppIconOption,
        result: Result<Void, ChangeAppIcon.Error>
    ) async throws -> SettingsViewModel {
        let sut = try SettingsViewModel.fixture
        await withDependencies {
            $0.changeAppIcon = ChangeAppIcon { (_: AppIconOption) async throws(ChangeAppIcon.Error) in
                try result.get()
            }
        } operation: {
            await sut.changeAppIcon(to: icon)
        }
        return sut
    }

    private func recordingOpenURL(into opened: LockIsolated<[URL]>) -> OpenURLEffect {
        OpenURLEffect { url in
            opened.withValue { $0.append(url) }
            return true
        }
    }
}
