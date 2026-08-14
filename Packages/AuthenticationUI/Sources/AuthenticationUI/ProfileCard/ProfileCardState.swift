import AuthenticationFeature

package enum ProfileCardState: Equatable {
    case loading
    case loaded(Profile)
    case failed
}
