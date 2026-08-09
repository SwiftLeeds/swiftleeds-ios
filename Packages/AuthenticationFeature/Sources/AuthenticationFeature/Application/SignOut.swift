import Dependencies

package struct SignOut: Sendable {
    private var perform: @Sendable () async throws -> Void

    private init(perform: @escaping @Sendable () async throws -> Void) {
        self.perform = perform
    }

    package func callAsFunction() async throws {
        try await perform()
    }
}

extension SignOut {
    package static var live: SignOut {
        SignOut {
            @Dependency(\.sessionStore) var sessionStore
            try await sessionStore.clear()
        }
    }
}
