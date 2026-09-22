import Dependencies

/// Changes the app's Home Screen icon.
package struct ChangeAppIcon: Sendable {
    private var perform: @Sendable (AppIconOption) async throws(AppIconChangeError) -> Void

    package init(perform: @escaping @Sendable (AppIconOption) async throws(AppIconChangeError) -> Void) {
        self.perform = perform
    }

    package func callAsFunction(to icon: AppIconOption) async throws(AppIconChangeError) {
        try await perform(icon)
    }
}

extension ChangeAppIcon: TestDependencyKey {
    package static let testValue = ChangeAppIcon(
        perform: { (_: AppIconOption) async throws(AppIconChangeError) in
            reportIssue("ChangeAppIcon is unimplemented")
            throw .refused
        }
    )
}

extension DependencyValues {
    package var changeAppIcon: ChangeAppIcon {
        get { self[ChangeAppIcon.self] }
        set { self[ChangeAppIcon.self] = newValue }
    }
}
