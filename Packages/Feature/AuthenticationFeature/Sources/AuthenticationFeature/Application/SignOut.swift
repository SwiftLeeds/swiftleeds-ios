import Dependencies

public struct SignOut: Sendable {
    private var perform: @Sendable () async throws -> Void

    public init(perform: @escaping @Sendable () async throws -> Void) {
        self.perform = perform
    }

    public func callAsFunction() async throws {
        try await perform()
    }
}

extension SignOut: DependencyKey {
    public static var liveValue: SignOut {
        SignOut {
            @Dependency(\.sessionStore) var sessionStore
            try await sessionStore.clear()
        }
    }

    public static let testValue = SignOut(perform: unimplemented("SignOut"))
}

extension DependencyValues {
    public var signOut: SignOut {
        get { self[SignOut.self] }
        set { self[SignOut.self] = newValue }
    }
}
