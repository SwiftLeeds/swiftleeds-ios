import LogKit
import Testing

@Suite struct LogFieldTests {
    @Test func whenBuiltAsOpen_shouldCarryOpenSensitivity() {
        let sut = LogField.open("category", "push")

        #expect(sut.sensitivity == .open)
        #expect(sut.value == .string("push"))
        #expect(sut.name == "category")
    }

    @Test func whenBuiltAsHashed_shouldCarryHashedSensitivity() {
        let sut = LogField.hashed("email", "ada@example.com")

        #expect(sut.sensitivity == .hashed)
    }

    @Test func whenBuiltAsSecret_shouldCarrySecretSensitivity() {
        let sut = LogField.secret("token", "abc123")

        #expect(sut.sensitivity == .secret)
    }

    @Test func whenSensitivitiesDiffer_shouldNotBeEqual() {
        #expect(LogField.open("a", 1) != LogField.hashed("a", 1))
    }
}
