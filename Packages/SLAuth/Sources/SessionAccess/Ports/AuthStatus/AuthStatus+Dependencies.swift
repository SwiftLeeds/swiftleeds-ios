import Dependencies

extension AuthStatus: TestDependencyKey {
    public static var testValue: Self {
        AuthStatus {
            unimplemented("AuthStatus is unimplemented", placeholder: .signedOut(SignedOut()))
        }
    }
}

extension DependencyValues {
    public var authStatus: AuthStatus {
        get { self[AuthStatus.self] }
        set { self[AuthStatus.self] = newValue }
    }
}

public struct SignedIn: Equatable, Hashable, Sendable {
    package init() {}
}

public struct SignedOut: Equatable, Hashable, Sendable {
    package init() {}
}

#warning("TODO: Move to test-support module")

// MARK: - Test support

public extension AuthStatus {
    static let signedIn = AuthStatus { .signedIn(SignedIn()) }
    static let signedOut = AuthStatus { .signedOut(SignedOut()) }
}
