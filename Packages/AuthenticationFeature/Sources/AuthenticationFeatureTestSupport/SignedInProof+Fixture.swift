import AuthenticationFeature

extension SignedInProof {
    /// A proof that its holder is signed in, for use in a test.
    public static var fixture: SignedInProof {
        get throws { try SignedInProof(Session(token: SessionToken("test-session-token"))) }
    }
}
