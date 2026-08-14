import AuthenticationFeature

package enum AccountViewState: Equatable {
    case loading
    case signedOut(signInRequired: Bool)
    case signedIn(SignedInProof)
}
