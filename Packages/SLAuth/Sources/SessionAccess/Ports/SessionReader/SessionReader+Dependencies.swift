import Dependencies

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
