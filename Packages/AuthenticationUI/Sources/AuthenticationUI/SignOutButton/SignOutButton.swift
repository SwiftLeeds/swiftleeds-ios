import SwiftUI

package struct SignOutButton: View {
    private let signOut: @MainActor () async -> Void

    @State private var isConfirming = false

    package init(signOut: @escaping @MainActor () async -> Void) {
        self.signOut = signOut
    }

    package var body: some View {
        Button("Sign Out", role: .destructive) {
            isConfirming = true
        }
        .confirmationDialog(
            "Sign out of your account?",
            isPresented: $isConfirming,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                Task { await signOut() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You'll need your ticket reference to sign back in.")
        }
    }
}
