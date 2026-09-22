import Dependencies

/// Changes the app's Home Screen icon.
package struct ChangeAppIcon: Sendable {
    package enum Error: Swift.Error, Equatable, Sendable {
        /// This device does not let apps change their icon.
        case unsupported

        /// The system refused the change.
        case refused
    }

    private var perform: @Sendable (AppIconOption) async throws(Error) -> Void

    package init(perform: @escaping @Sendable (AppIconOption) async throws(Error) -> Void) {
        self.perform = perform
    }

    package func callAsFunction(to icon: AppIconOption) async throws(Error) {
        try await perform(icon)
    }
}

extension ChangeAppIcon: TestDependencyKey {
    package static let testValue = ChangeAppIcon(
        perform: { (_: AppIconOption) async throws(Error) in
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
