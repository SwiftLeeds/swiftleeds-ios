import Dependencies

public struct SessionReader: Sendable {
    public var current: @Sendable () async -> Session?
    #warning("Remove `isSignedIn. No longer relevant as existence of `Session` indicates signed-in state")
    public var isSignedIn: @Sendable () async -> Bool

    public init(
        current: @Sendable @escaping () async -> Session?,
        isSignedIn: @Sendable @escaping () async -> Bool
    ) {
        self.current = current
        self.isSignedIn = isSignedIn
    }
}

extension SessionReader: TestDependencyKey {
    public static var testValue: Self {
        SessionReader(
            current: { unimplemented("SessionReader.current is unimplemented", placeholder: nil) },
            isSignedIn: { unimplemented("SessionReader.isSignedIn is unimplemented", placeholder: false) }
        )
    }
}

extension DependencyValues {
    public var sessionReader: SessionReader {
        get { self[SessionReader.self] }
        set { self[SessionReader.self] = newValue }
    }
}

