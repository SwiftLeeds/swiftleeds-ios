import AuthenticationDomain

extension SignedInProof {
    /// A proof that its holder is signed in, for use in a test.
    ///
    /// - Throws: Nothing in practice. The fixed token text is not blank, so `SessionToken.ParsingError.empty`
    ///   cannot occur.
    public static var fixture: SignedInProof {
        get throws { try SignedInProof(Session(token: SessionToken("test-session-token"))) }
    }
}
