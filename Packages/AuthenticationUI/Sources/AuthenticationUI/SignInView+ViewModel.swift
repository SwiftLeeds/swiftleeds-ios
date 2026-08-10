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
            case failed(AuthenticationError)
        }

        @ObservationIgnored
        @Dependency(\.signIn) private var signIn

        package var email = ""
        package var ticketReference = ""
        package private(set) var phase: Phase = .editing
        package var onSignedIn: @MainActor () -> Void = {}

        package init() {}

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
            } catch let error as AuthenticationError {
                phase = .failed(error)
            } catch {
                phase = .failed(.unknown)
            }
        }
    }
}
