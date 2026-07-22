#warning("Will need to remove Domain import once SecureStoreKey is moved to `SecureStore` target")
import IdentityAndAccessDomain

extension SecureStoreKey {
    static let authToken = SecureStoreKey("identity.authToken")
}
