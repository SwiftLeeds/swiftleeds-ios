import SwiftUI
import UIDesign

/// A view that lets a person sign in with their ticket's email address and
/// reference.
struct SignInScreen: View {
    /// Which field holds the keyboard focus.
    private enum Field: Hashable {
        /// The email address field.
        case email

        /// The ticket reference field.
        case ticketReference
    }

    /// Where signing in has got to.
    private enum Phase: Equatable {
        /// Waiting for this person to type and submit.
        case editing

        /// Waiting for the pretend server to answer.
        case submitting
    }

    /// How long the gallery pretends the server takes to answer.
    private static let pretendDelay = Duration.seconds(1)

    /// Dismisses the sheet once signing in finishes.
    @Environment(\.dismiss) private var dismiss

    /// The email address this person has typed.
    @State private var email: String

    /// The ticket reference this person has typed.
    @State private var ticketReference: String

    /// Where signing in has got to.
    @State private var phase = Phase.editing

    /// Which field holds the keyboard focus.
    @FocusState private var focus: Field?

    /// Creates the screen, with the fields seeded from the state the gallery
    /// asked it to open with.
    ///
    /// - Parameter state: The state the screen opens in.
    init(opensWith state: SignInState) {
        _email = State(initialValue: state.email)
        _ticketReference = State(initialValue: state.ticketReference)
    }

    /// Whether both fields hold enough to submit.
    ///
    /// The gallery checks only that both fields have text; the shipping app
    /// validates the values.
    private var canSubmit: Bool {
        !email.isEmpty && !ticketReference.isEmpty && phase != .submitting
    }

    var body: some View {
        List {
            Section {
                heading
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                    .padding(.top, .large)
            }

            Section {
                emailRow
                ticketReferenceRow
            }
        }
        .listStyle(.insetGrouped)
        .safeAreaBar(edge: .bottom) {
            signInButton
        }
        .task(id: phase) {
            guard phase == .submitting else { return }
            // The task modifier cancels this when the view leaves, so the
            // sleep then has nothing left to do.
            try? await Task.sleep(for: Self.pretendDelay)
            dismiss()
        }
    }

    /// The glyph, the prompt and the sentence explaining what is needed.
    private var heading: some View {
        VStack(alignment: .leading, spacing: .medium) {
            Image(systemName: "ticket")
                .font(.largeTitle)
                .foregroundStyle(.brandPrimary)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: .xSmall) {
                Text("Sign in with your ticket")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.textPrimary)

                Text(
                    """
                    You'll need the email address you bought your ticket \
                    with and the ticket reference from your confirmation \
                    email.
                    """
                )
                .font(.body)
                .foregroundStyle(.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    /// The row that reads the email address this person typed.
    private var emailRow: some View {
        LabeledContent("Email address") {
            TextField("Email address", text: $email, prompt: Text("name@example.com"))
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .multilineTextAlignment(.leading)
                .focused($focus, equals: .email)
                .onSubmit { focus = .ticketReference }
        }
        .disabled(phase == .submitting)
    }

    /// The row that reads the ticket reference this person typed.
    private var ticketReferenceRow: some View {
        LabeledContent("Ticket reference") {
            TextField("Ticket reference", text: $ticketReference, prompt: Text("ABCD-1"))
                .textInputAutocapitalization(.characters)
                .autocorrectionDisabled()
                .submitLabel(.go)
                .multilineTextAlignment(.leading)
                .focused($focus, equals: .ticketReference)
                .onSubmit {
                    if canSubmit {
                        signIn()
                    }
                }
        }
        .disabled(phase == .submitting)
    }

    /// The action that submits the fields.
    private var signInButton: some View {
        Button {
            signIn()
        } label: {
            Group {
                if phase == .submitting {
                    ProgressView()
                } else {
                    Text("Sign In")
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glassProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .tint(.brandPrimary)
        .disabled(!canSubmit)
        .padding(.horizontal, .large)
    }

    /// Starts submitting the typed fields.
    private func signIn() {
        phase = .submitting
    }
}
