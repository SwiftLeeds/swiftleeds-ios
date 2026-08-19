import Foundation

func attendeeJSON(
    email: String = "ada@example.com",
    reference: String = "ABCD-12"
) -> Data {
    Data("""
    {
        "ticket": {
            "first_name": "Ada",
            "last_name": "Lovelace",
            "email": "\(email)",
            "avatar_url": "https://example.com/avatar.png",
            "qr_url": "https://example.com/qr.png",
            "reference": "\(reference)",
            "slug": "ti_pxqFKr9pPWd6VeYKvMBKpjQ"
        }
    }
    """.utf8)
}
