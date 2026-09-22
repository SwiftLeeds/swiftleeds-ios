import Dependencies
import SettingsUI
import Sharing
import Testing

@Suite struct SelectedAppIconTests {
    @Test func whenNoIconIsStored_shouldReturnGeneric() {
        @Shared(.selectedAppIcon) var icon

        #expect(icon == .generic)
    }

    @Test func whenIconIsSelected_shouldStoreItsRawValueUnderSelectedAppIcon() {
        @Dependency(\.defaultAppStorage) var store
        @Shared(.selectedAppIcon) var icon

        $icon.withLock { $0 = .space }

        #expect(store.string(forKey: "selectedAppIcon") == "AppIcon-Space")
    }

    @Test func whenIconWasStoredBeforeThisVersion_shouldReturnIt() {
        @Dependency(\.defaultAppStorage) var store
        store.set("AppIcon-Olympics", forKey: "selectedAppIcon")

        @Shared(.selectedAppIcon) var icon

        #expect(icon == .olympics)
    }
}
