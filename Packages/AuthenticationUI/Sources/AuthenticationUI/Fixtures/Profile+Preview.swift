import AuthenticationFeature
import Foundation

#if DEBUG
package extension Profile {
    static var preview: Profile {
        Profile(
            name: "Ada Lovelace",
            emailAddress: "ada@example.com",
            avatarURL: URL(string: "https://example.com/avatar.png")!,
            qrCodeURL: URL(string: "https://example.com/qr.png")!,
            ticketReference: "ABCD-1"
        )
    }
}
#endif
