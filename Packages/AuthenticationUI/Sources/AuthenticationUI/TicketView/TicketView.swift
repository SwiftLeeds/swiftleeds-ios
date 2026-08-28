import AuthenticationFeature
import Foundation
import SwiftUI

/// The attendee's ticket, shown so staff and sponsors can scan it.
///
/// The screen brightens while it is open and goes back to how it was on the way out, including
/// when the app is sent to the background.
package struct TicketView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel = ViewModel()

    private let slug: TicketSlug
    private let reference: String
    private let name: PersonNameComponents

    package init(slug: TicketSlug, reference: String, name: PersonNameComponents) {
        self.slug = slug
        self.reference = reference
        self.name = name
    }

    package var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer(minLength: 0)

                Barcode(.qr(QRCode.Payload(String(slug)))) {
                    unreadable
                }
                .frame(maxWidth: 320)
                .accessibilityElement()
                .accessibilityLabel("QR code")
                .accessibilityHint("Hold this up to be scanned")

                identity

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .navigationTitle("Ticket")
            .inlineNavigationTitle()
            .toolbar {
                Button("Done") { dismiss() }
            }
        }
        .presentationDragIndicator(.visible)
        .onAppear { viewModel.beginDisplaying() }
        .onDisappear { viewModel.endDisplaying() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                viewModel.beginDisplaying()
            } else {
                viewModel.endDisplaying()
            }
        }
    }

    private var identity: some View {
        VStack(spacing: 4) {
            Text(verbatim: reference)
                .font(.title2.weight(.semibold).monospaced())
                .textSelection(.enabled)

            Text(name.formatted())
                .foregroundStyle(.secondary)
        }
    }

    private var unreadable: some View {
        VStack(spacing: 8) {
            Label("We can't show your QR code", systemImage: "exclamationmark.triangle")

            Text("Show your ticket reference to a member of staff and they'll check you in.")
                .font(.footnote)
        }
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding()
    }
}

private extension View {
    func inlineNavigationTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}

#Preview {
    TicketView(
        slug: try! TicketSlug("ti_pxqFKr9pPWd6VeYKvMBKpjQ"),
        reference: "YZHI-1",
        name: PersonNameComponents(givenName: "Paul", familyName: "Willis")
    )
}
