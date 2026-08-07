import SwiftUI

public struct SignInView: View {
    @State private var viewModel = ViewModel()

    public init() {}

    public var body: some View {
        List {
            Section(
                content: {
                    Text("Signed In: \(viewModel.isSignedIn.description)")
                }
            )

            Section(
                content: {
                    TextField("Email address", text: $viewModel.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }, header: {
                    Text("Email address")
                }, footer: {
                    Text("The email address you used to buy your ticket")
                        .font(.footnote)
                }
            )

            Section(
                content: {
                    TextField("Ticket Reference", text: $viewModel.ticketReference)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                }, header: {
                    Text("Ticket Reference")
                }, footer: {
                    Text("It’s in your confirmation email - for example, 'ABCD-1'")
                        .font(.footnote)
                }
            )

            Section {
                Button("Sign in") {
                    viewModel.signInTapped()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SignInView()
            .navigationTitle("Sign in")
    }
}
