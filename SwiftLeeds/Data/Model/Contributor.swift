//
//  Contributor.swift
//  SwiftLeeds
//
//  Created by LUCKY AGARWAL on 20/07/22.
//

import Foundation

struct Contributor: Hashable {
    let name: String
    let oneLiner: String
    let imageURL: URL?
    let aboutDescription: String
    let socialList: [SocialHandle]

    struct SocialHandle: Hashable {
        let socialType: String
        let socialValue: String
    }

}

// MARK: - Static Data
extension Contributor {
    static let contributors = [person1, person2, person3, person4, person5]
    
    static let person1 = Contributor(
        name: "Naruto",
        oneLiner: "Good Guy with yellow Hair",
        imageURL:URL(string:  "https://www.giantbomb.com/a/uploads/scale_super/16/164924/2345829-naruto_gokucostume.jpg"),
        aboutDescription: "Good Guy with yellow Hair, Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        socialList: [
            SocialHandle(socialType: "Twitter", socialValue: "@narutouzumaki"),
            SocialHandle(socialType: "Linkedin", socialValue: "@narutouzumakiLinkedin"),
            SocialHandle(socialType: "Website", socialValue: "www.narutouzumaki.in")
        ])
    
    static let person2 = Contributor(
        name: "Goku",
        oneLiner: "Good Guy with Black Hair, God of saiyans",
        imageURL: URL(string:  "https://www.giantbomb.com/a/uploads/square_medium/0/1992/3155344-apps.49085.14307533965729354.229591ed-f307-4dad-bf3b-285c2a19fff3.jpeg"),
        aboutDescription: "Good Guy with Black Hair, God of saiyans, Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        socialList: [
            SocialHandle(socialType: "Twitter", socialValue: "@goodgoku"),
            SocialHandle(socialType: "Linkedin", socialValue: "@goodgokuLinkedin"),
            SocialHandle(socialType: "Website", socialValue: "www.goodgoku.in")
        ])
    
    static let person3 = Contributor(
        name: "sakura",
        oneLiner: "Good Gal with pink Hair, brave gal",
        imageURL:URL(string:  "https://www.giantbomb.com/a/uploads/original/0/4340/494298-25.jpg"),
        aboutDescription: "Good Gal with pink Hair, brave gal, Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        socialList: [
            SocialHandle(socialType: "Twitter", socialValue: "@pinksakura"),
            SocialHandle(socialType: "Linkedin", socialValue: "@pinksakuraLinkedin"),
            SocialHandle(socialType: "Website", socialValue: "www.pinksakura.in")
        ])
    
    static let person4 = Contributor(
        name: "Ryuk",
        oneLiner: "Good Scary Guy from Hell",
        imageURL: URL(string : "https://w7.pngwing.com/pngs/15/1021/png-transparent-ryuk-light-yagami-rem-death-note-shinigami-others-thumbnail.png"),
        aboutDescription: "Good Scary Guy from Hell, Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        socialList: [
            SocialHandle(socialType: "Twitter", socialValue: "@ryuktheguy"),
            SocialHandle(socialType: "Linkedin", socialValue: "@ryuktheguyLinkedin"),
            SocialHandle(socialType: "Website", socialValue: "www.ryuktheguy.in")
        ])
    
    static let person5 = Contributor(
        name: "Light Yagami",
        oneLiner: "Light the master mind behind all the deaths in death Note",
        imageURL: URL(string:  "https://w7.pngwing.com/pngs/14/564/png-transparent-light-yagami-misa-amane-ryuk-death-note-shinigami-manga-fictional-character-death-note-thumbnail.png"),
        aboutDescription: "Light the master mind behind all the deaths in death Note, Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
        socialList: [
            SocialHandle(socialType: "Twitter", socialValue: "@lightguy"),
            SocialHandle(socialType: "Linkedin", socialValue: "@lightguyLinkedin"),
            SocialHandle(socialType: "Website", socialValue: "www.lightguy.in")
        ])
}
