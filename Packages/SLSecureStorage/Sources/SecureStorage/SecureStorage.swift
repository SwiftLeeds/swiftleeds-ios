import Dependencies
import Foundation

#warning("Move to own `Capability` target")

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

#warning("Replace with `KeychainSecureStorage`")

extension SecureStorage: DependencyKey {
    static public var liveValue: SecureStorage {
        let queue = DispatchQueue(label: "securestore")
        var dictionary: [SecureStorageKey: Data] = [:]

        return SecureStorage(
            data: { key in
                print(">>> SecureStorage.data entered")
                return await withCheckedContinuation { continuation in
                    queue.async {
                        let value = dictionary[key]
                        print(">>> SecureStorage.data found value: \(value) for key: \(key)")
                        continuation.resume(returning: value)
                    }
                }
            },
            set: { data, key in
                print(">>> SecureStorage.set entered")
                await withCheckedContinuation { continuation in
                    print(">>> SecureStorage.set = \(data) for key: \(key)")
                    queue.async {
                        dictionary[key] = data
                        continuation.resume(returning: ())
                    }
                }
            },
            remove: { key in
                print(">>> SecureStorage.remove entered")
                await withCheckedContinuation { continuation in
                    print(">>> SecureStorage.remove value for key: \(key)")
                    queue.async {
                        dictionary.removeValue(forKey: key)
                        continuation.resume(returning: ())
                    }
                }
            }
        )
    }
}
