import Dependencies
import Foundation

public struct SecureStorage: Sendable {
    public var data: @Sendable(SecureStorageKey) async throws -> Data?
    public var set: @Sendable (Data, SecureStorageKey) async throws -> Void
    public var remove: @Sendable (SecureStorageKey) async throws -> Void
}

extension SecureStorage: TestDependencyKey {
    struct TestError: Error {}

    public static var testValue: SecureStorage {
        SecureStorage(
            data: { _ in
                reportIssue("SecureStorage.data is unimplemented")
                throw TestError()
            },
            set: { _, _ in
                reportIssue("SecureStorage.set is unimplemented")
                throw TestError()
            },
            remove: { _ in
                reportIssue("SecureStorage.remove is unimplemented")
                throw TestError()
            }
        )
    }
}

extension DependencyValues {
    public var secureStorage: SecureStorage {
        get { self[SecureStorage.self] }
        set { self[SecureStorage.self] = newValue }
    }
}
