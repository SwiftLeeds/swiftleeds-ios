#warning("Can maybe remove this import once `EmailAddress` and `TicketReference` are moved to a different target")
import IdentityAndAccessDomain

public struct SignIn: Sendable {
    public typealias Input = @Sendable (_ emailAddress: EmailAddress, _ ticketReference: TicketReference) async throws -> Void

    public var run: Input

    public init(run: @escaping Input) {
        self.run = run
    }
}

extension SignIn {
    public func callAsFunction(
        emailAddress: EmailAddress,
        ticketReference: TicketReference
    ) async throws -> Void {
        try await run(emailAddress, ticketReference)
    }
}
