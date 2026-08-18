import AuthenticationFeature
import Dependencies
import Observation

extension SignInView {
    @MainActor
    @Observable
    package final class ViewModel {
        package enum Phase: Equatable {
            case editing
            case submitting
            case failed(SignInError)
        }

        @ObservationIgnored
        @Dependency(\.signIn) private var signIn

        package var email = ""
        package var ticketReference = ""
        package private(set) var phase: Phase = .editing
        package var onSignedIn: @MainActor () -> Void = {}

        package init() {}

        /// Which alert a failure warrants, if any.
        ///
        /// Names the alert rather than carrying its words: the words are literals in the view, so
        /// there is no title that could be absent. A rejected ticket reference deliberately has no
        /// alert, because it is shown next to the field the user needs to correct.
        package enum Alert: Equatable {
            case cannotConnect
            case unexpected
        }

        package var alert: Alert? {
            switch phase {
            case .failed(.couldNotReachServer):
                .cannotConnect
            case .failed(.unknown):
                .unexpected
            case .failed(.invalidCredentials):
                nil
            case .editing:
                nil
            case .submitting:
                nil
            }
        }

        package var credential: Credential? {
            try? Credential(
                email: EmailAddress(email),
                ticketReference: TicketReference(ticketReference)
            )
        }

        package var isSubmitting: Bool { phase == .submitting }

        package var canSubmit: Bool {
            credential != nil && !isSubmitting
        }

        package func submit() async {
            guard !isSubmitting, let credential else { return }
            phase = .submitting
            do {
                try await signIn(credential)
                phase = .editing
                onSignedIn()
            } catch let error as SignInError {
                phase = .failed(error)
            } catch {
                phase = .failed(.unknown)
            }
        }

        package func dismissError() {
            guard case .failed = phase else { return }
            phase = .editing
        }
    }
}
