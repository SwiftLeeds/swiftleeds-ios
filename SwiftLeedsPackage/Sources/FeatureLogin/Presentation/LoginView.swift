import SwiftUI

public struct LoginView: View {
    @State private var viewModel = ViewModel()

    public init() {}

    public var body: some View {
        List {
            Section(
                content: {
                    Text("JWT: \(viewModel.jwt ?? "Nil")")
                }
            )

            Section(
                content: {
                    TextField("Email address", text: $viewModel.emailAddress)
                        .keyboardType(.emailAddress)
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
                }, header: {
                    Text("Ticket Reference")
                }, footer: {
                    Text("It’s in your confirmation email - for example, 'ABCD-1'")
                        .font(.footnote)
                }
            )

            Section {
                Button("Log in") {
                    viewModel.logInTapped()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .navigationTitle("Log in")
    }
}
