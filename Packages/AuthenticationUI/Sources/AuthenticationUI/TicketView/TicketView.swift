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
            TicketViewContent(code: code, reference: reference, name: name)
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

    @MainActor private var code: TicketCode {
        TicketCode(drawing: .qr(QRCode.Payload(String(slug))))
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

#if DEBUG
#Preview {
    TicketView(
        slug: Profile.preview.ticketSlug,
        reference: Profile.preview.ticketReference,
        name: Profile.preview.name
    )
}
#endif
