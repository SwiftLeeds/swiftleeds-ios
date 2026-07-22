import Dependencies
import Foundation

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

