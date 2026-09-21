// The links and short text in `about.json`, bundled with this package.
struct AboutContent: Decodable {
    struct URLs: Decodable {
        let venue: String
        let codeOfConduct: String
        let reportAProblem: String
        let slack: String
        let youtube: String
    }

    let urls: URLs
    let truncatedAboutText: String
}
