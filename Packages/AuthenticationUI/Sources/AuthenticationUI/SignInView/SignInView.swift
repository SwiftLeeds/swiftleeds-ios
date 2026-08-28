import AuthenticationFeature
import Dependencies
import SwiftUI

public struct SignInView: View {
    @State private var viewModel: ViewModel

    public init(onSignedIn: @escaping @MainActor () -> Void) {
        let viewModel = ViewModel()
        viewModel.onSignedIn = onSignedIn
        _viewModel = State(wrappedValue: viewModel)
    }

    public var body: some View {
        List {
            Section {
                TextField("Email address", text: $viewModel.email)
                    .emailFieldStyle()
            } header: {
                Text("Email address")
            } footer: {
                Text("The email address you used to buy your ticket")
                    .font(.footnote)
            }

            Section {
                TextField("Ticket reference", text: $viewModel.ticketReference)
                    .ticketReferenceFieldStyle()
            } header: {
                Text("Ticket reference")
            } footer: {
                Text("You'll find it in your confirmation email. It looks like ABCD-1.")
                    .font(.footnote)
            }

            if case .failed(.invalidCredentials) = viewModel.phase {
                Section {
                    Text(
                        "We can't find a ticket for that email address and ticket reference. Check them and try again."
                    )
                    .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    Task { await viewModel.submit() }
                } label: {
                    switch viewModel.phase {
                    case .editing:
                        Text("Sign In")
                    case .failed:
                        Text("Sign In")
                    case .submitting:
                        ProgressView()
                    }
                }
                .disabled(!viewModel.canSubmit)
            }
        }
        .disabled(viewModel.isSubmitting)
        .alert("We can't connect", isPresented: presenting(.cannotConnect)) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Check your connection and try again.")
        }
        .alert("We can't sign you in", isPresented: presenting(.unexpected)) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Something went wrong at our end. Try again in a moment.")
        }
    }

    private func presenting(_ alert: ViewModel.Alert) -> Binding<Bool> {
        Binding(
            get: { viewModel.alert == alert },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissError()
                }
            }
        )
    }
}

private extension View {
    func emailFieldStyle() -> some View {
        #if os(iOS)
        keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        #else
        autocorrectionDisabled()
        #endif
    }

    func ticketReferenceFieldStyle() -> some View {
        #if os(iOS)
        textInputAutocapitalization(.characters)
            .autocorrectionDisabled()
        #else
        autocorrectionDisabled()
        #endif
    }
}

#Preview {
    NavigationStack {
        SignInView(onSignedIn: {})
            .navigationTitle("Sign In")
    }
}
