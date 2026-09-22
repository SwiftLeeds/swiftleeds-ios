import Dependencies
import DependenciesTestSupport
import SettingsUI
import Sharing
import Testing

@MainActor
@Suite struct SettingsViewModelTests {
    @Test func whenIconChangeSucceeds_shouldReturnNewIcon() async {
        let sut = await changingIcon(to: .space, result: .success(()))

        #expect(sut.currentIcon == .space)
    }

    @Test func whenIconChangeSucceeds_shouldStoreNewIcon() async {
        _ = await changingIcon(to: .olympics, result: .success(()))

        @Shared(.selectedAppIcon) var storedIcon
        #expect(storedIcon == .olympics)
    }

    @Test(.dependencies, arguments: [ChangeAppIcon.Error.unsupported, .refused])
    func whenIconChangeFails_shouldShowIconError(error: ChangeAppIcon.Error) async {
        let sut = await changingIcon(to: .space, result: .failure(error))

        #expect(sut.showingIconError)
    }

    @Test(.dependencies, arguments: [ChangeAppIcon.Error.unsupported, .refused])
    func whenIconChangeFails_shouldKeepCurrentIcon(error: ChangeAppIcon.Error) async {
        let sut = await changingIcon(to: .space, result: .failure(error))

        #expect(sut.currentIcon == .generic)
    }

    private func changingIcon(
        to icon: AppIconOption,
        result: Result<Void, ChangeAppIcon.Error>
    ) async -> SettingsViewModel {
        await withDependencies {
            $0.changeAppIcon = ChangeAppIcon { (_: AppIconOption) async throws(ChangeAppIcon.Error) in
                try result.get()
            }
        } operation: {
            let sut = SettingsViewModel()
            await sut.changeAppIcon(to: icon)
            return sut
        }
    }
}
