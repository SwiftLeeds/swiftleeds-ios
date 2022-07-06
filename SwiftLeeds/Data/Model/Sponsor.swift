//
//  Sponsor.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 01/07/2022.
//

import Foundation

// These should come from an API eventually
struct Sponsor: Hashable {
    let name: String
    let oneLiner: String
    let imageURL: URL?
    let link: URL?
}

// MARK: - Static data
extension Sponsor {
    static let platinum = [codemagic, stream]
    static let gold = [mkodo, and, xdesign, bitrise]

    // All of these images are temporary until this is API based

    // Platinum
    static let codemagic = Sponsor(
        name: "codemagic",
        oneLiner: "CI/CD for mobile that matches your needs",
        imageURL: URL(string: "https://miro.medium.com/max/3150/1*8FOeoWB-4SAzwTXFBWUTeg.jpeg"),
        link: URL(string: "https://codemagic.io/")
    )

    static let stream = Sponsor(
        name: "Stream",
        oneLiner: "Build In-App Chat + Feeds, Faster",
        imageURL: URL(string: "https://pbs.twimg.com/media/E20a5PKWUAELWeX.png"),
        link: URL(string: "https://getstream.io/chat/sdk/swiftui/?utm_source=SwiftLeeds&utm_medium=Whole_Event_L&utm_content=Developer&utm_campaign=SwiftLeeds_Oct2022")
    )

    // Gold
    static let mkodo = Sponsor(
        name: "mkodo",
        oneLiner: "Let's innovate lottery and gaming",
        imageURL: URL(string: "https://lafleurs.com/wp-content/uploads/2019/06/Mkodo_slate.png"),
        link: URL(string: "https://www.mkodo.com/s/careers")
    )

    static let and = Sponsor(
        name: "AND Digital",
        oneLiner: "Build better digital products AND stronger teams",
        imageURL: URL(string: "https://launchpadreading.org.uk/wp-content/uploads/2020/06/AND-logo.png"),
        link: URL(string: "https://www.and.digital/join/open-roles")
    )

    static let xdesign = Sponsor(
        name: "xdesign",
        oneLiner: "Web and mobile product development",
        imageURL: URL(string: "https://thewealthmosaic.s3.amazonaws.com/media/Logo_xDesign.png"),
        link: URL(string: "https://www.xdesign.com/")
    )

    static let bitrise = Sponsor(
        name: "Bitrise",
        oneLiner: "Build better mobile applications, faster",
        imageURL: URL(string: "https://assets-global.website-files.com/5db35de024bb983af1b4e151/5e6f9ccda4e7ff12841abe18_Bitrise%20Logo%20-%20White%20Bg.png"),
        link: URL(string: "https://www.bitrise.io/")
    )
}
