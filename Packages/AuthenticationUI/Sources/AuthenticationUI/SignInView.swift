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
                Text("Ticket Reference")
            } footer: {
                Text("It's in your confirmation email - for example, 'ABCD-1'")
                    .font(.footnote)
            }

            if case .failed(.invalidCredentials) = viewModel.phase {
                Section {
                    Text("We couldn't find a ticket for that email and reference. Please check them and try again.")
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    Task { await viewModel.submit() }
                } label: {
                    switch viewModel.phase {
                    case .editing:
                        Text("Sign in")
                    case .failed:
                        Text("Sign in")
                    case .submitting:
                        ProgressView()
                    }
                }
                .disabled(!viewModel.canSubmit)
            }
        }
        .disabled(viewModel.isSubmitting)
        .alert("Something went wrong", isPresented: presentingUnknownError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please try again.")
        }
    }

    private var presentingUnknownError: Binding<Bool> {
        Binding(
            get: { viewModel.phase == .failed(.unknown) },
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
            .navigationTitle("Sign in")
    }
}
