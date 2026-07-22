import Dependencies
import Foundation

#warning("Move to own `Capability` target")

public struct SecureStore: Sendable {
    public var data: @Sendable(SecureStoreKey) async throws -> Data?
    public var set: @Sendable (Data, SecureStoreKey) async throws -> Void
    public var remove: @Sendable (SecureStoreKey) async throws -> Void
}

extension SecureStore: TestDependencyKey {
    struct TestError: Error {}

    public static var testValue: SecureStore {
        SecureStore(
            data: { _ in
                reportIssue("SecureStore.data is unimplemented")
                throw TestError()
            },
            set: { _, _ in
                reportIssue("SecureStore.set is unimplemented")
                throw TestError()
            },
            remove: { _ in
                reportIssue("SecureStore.remove is unimplemented")
                throw TestError()
            }
        )
    }
}

extension DependencyValues {
    public var secureStore: SecureStore {
        get { self[SecureStore.self] }
        set { self[SecureStore.self] = newValue }
    }
}

#warning("Replace with `KeychainSecureStore`")

extension SecureStore: DependencyKey {
    static public var liveValue: SecureStore {
        let queue = DispatchQueue(label: "securestore")
        var dictionary: [SecureStoreKey: Data] = [:]

        return SecureStore(
            data: { key in
                print(">>> SecureStore.data entered")
                return await withCheckedContinuation { continuation in
                    queue.async {
                        let value = dictionary[key]
                        print(">>> SecureStore.data found value: \(value) for key: \(key)")
                        continuation.resume(returning: value)
                    }
                }
            },
            set: { data, key in
                print(">>> SecureStore.set entered")
                await withCheckedContinuation { continuation in
                    print(">>> SecureStore.set = \(data) for key: \(key)")
                    queue.async {
                        dictionary[key] = data
                        continuation.resume(returning: ())
                    }
                }
            },
            remove: { key in
                print(">>> SecureStore.remove entered")
                await withCheckedContinuation { continuation in
                    print(">>> SecureStore.remove value for key: \(key)")
                    queue.async {
                        dictionary.removeValue(forKey: key)
                        continuation.resume(returning: ())
                    }
                }
            }
        )
    }
}
