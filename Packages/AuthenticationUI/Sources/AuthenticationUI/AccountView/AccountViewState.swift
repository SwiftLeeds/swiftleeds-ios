import AuthenticationFeature

package enum AccountViewState: Equatable {
    case loading
    case signedOut
    case signedIn(SignedInProof)
}
