import SecureStorageKit

extension SecureStorage {
    static func failing(with error: some Error & Sendable) -> SecureStorage {
        SecureStorage(
            data: { _ in throw error },
            set: { _, _ in throw error },
            remove: { _ in throw error }
        )
    }
}
