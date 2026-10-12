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

        /// The server has refused the typed fields.
        case rejected
    }

    /// How long the gallery pretends the server takes to answer.
    private static let pretendDelay = Duration.seconds(1)

    /// Dismisses the sheet once signing in finishes.
    @Environment(\.dismiss) private var dismiss

    /// Whether this person has asked for less movement on screen.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The email address this person has typed.
    @State private var email: String

    /// The ticket reference this person has typed.
    @State private var ticketReference: String

    /// Where signing in has got to.
    @State private var phase = Phase.editing

    /// Which field holds the keyboard focus.
    @FocusState private var focus: Field?

    /// Whether VoiceOver should move to the rejection message.
    @AccessibilityFocusState private var isRejectionFocused: Bool

    /// Whether the screen opened already rejected.
    private let opensRejected: Bool

    /// Creates the screen, with the fields seeded from the state the gallery
    /// asked it to open with.
    ///
    /// - Parameter state: The state the screen opens in.
    init(opensWith state: SignInState) {
        _email = State(initialValue: state.email)
        _ticketReference = State(initialValue: state.ticketReference)
        _phase = State(initialValue: state.isRejected ? .rejected : .editing)
        opensRejected = state.isRejected
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
                    .padding(.top, .large)
            }

            if phase == .rejected {
                Section {
                    rejectionSection
                }
            }

            Section {
                emailSection
            } header: {
                Text("Email address")
            } footer: {
                Text("The email address you used to buy your ticket")
            }

            Section {
                ticketReferenceSection
            } header: {
                Text("Ticket reference")
            } footer: {
                Text("You'll find it in your confirmation email. It looks like ABCD-1.")
            }

            Section {
                signInButton
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
            }
        }
        .listStyle(.insetGrouped)
        .toolbar { keyboardBar }
        .task(id: phase) {
            guard phase == .submitting else { return }
            // The task modifier cancels this when the view leaves, so the
            // sleep then has nothing left to do.
            try? await Task.sleep(for: Self.pretendDelay)
            dismiss()
        }
        .sensoryFeedback(.error, trigger: phase) { _, new in new == .rejected }
        .onAppear {
            if opensRejected {
                withAnimation(reduceMotion ? nil : .default) {
                    phase = .rejected
                }
            }
            if phase == .rejected {
                isRejectionFocused = true
            }
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

    /// The field that reads the email address this person typed.
    private var emailSection: some View {
        TextField("Email address", text: $email, prompt: Text(verbatim: ""))
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.next)
            .multilineTextAlignment(.leading)
            .focused($focus, equals: .email)
            .onSubmit { focus = .ticketReference }
            .onChange(of: email) { clearRejection() }
            .disabled(phase == .submitting)
    }

    /// The field that reads the ticket reference this person typed.
    private var ticketReferenceSection: some View {
        TextField("Ticket reference", text: $ticketReference, prompt: Text(verbatim: ""))
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
            .onChange(of: ticketReference) { clearRejection() }
            .disabled(phase == .submitting)
    }

    /// The controls above the keyboard that move between fields and close it.
    @ToolbarContentBuilder private var keyboardBar: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Button {
                focus = .email
            } label: {
                Label("Previous field", systemImage: "chevron.up")
            }
            .disabled(focus == .email)

            Button {
                focus = .ticketReference
            } label: {
                Label("Next field", systemImage: "chevron.down")
            }
            .disabled(focus == .ticketReference)
        }

        ToolbarSpacer(.flexible, placement: .keyboard)

        ToolbarItem(placement: .keyboard) {
            Button("Done") {
                focus = nil
            }
        }
    }

    /// The message explaining why the server refused the typed fields.
    private var rejectionSection: some View {
        Label(
            "We can't find a ticket for that email address and ticket reference. Check them and try again.",
            systemImage: "exclamationmark.circle"
        )
        .foregroundStyle(.error)
        .accessibilityFocused($isRejectionFocused)
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
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .controlSize(.large)
        .tint(.brandPrimary)
        .disabled(!canSubmit)
    }

    /// Starts submitting the typed fields.
    private func signIn() {
        phase = .submitting
    }

    /// Returns a rejected screen to editing, now that a field has changed.
    private func clearRejection() {
        if phase == .rejected {
            phase = .editing
        }
    }
}
