import AuthenticationFeature
import Dependencies
import SwiftUI

public struct SignInView: View {
    @State private var viewModel = ViewModel()

    public init() {}

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
                TextField("Ticket Reference", text: $viewModel.ticketReference)
                    .ticketReferenceFieldStyle()
            } header: {
                Text("Ticket Reference")
            } footer: {
                Text("It's in your confirmation email - for example, 'ABCD-1'")
                    .font(.footnote)
            }

            if case let .failed(error) = viewModel.phase {
                Section {
                    Text(error.message).foregroundStyle(.red)
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
    }
}

private extension AuthenticationError {
    var message: String {
        switch self {
        case .invalidCredentials:
            "We couldn't find a ticket for that email and reference. Please check them and try again."
        case .unknown:
            "Something went wrong. Please try again."
        }
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
        SignInView()
            .navigationTitle("Sign in")
    }
}
