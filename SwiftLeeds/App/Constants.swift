//
//  Constants.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 29/06/2022.
//

import CoreGraphics

enum Constants {
    static let cellRadius: CGFloat = 12
    static let compactCellMinimumHeight: CGFloat = 53
    static let cellMinimumHeight: CGFloat = 65
    static let bottomSheetRadius: CGFloat = 30
    static let minHeightRatio: CGFloat = 0.3
    static let maxHeightRatio: CGFloat = 0.5
    static let snapRatio: CGFloat = 0.25
}

enum Padding {
    static let screen: CGFloat = 16
    static let cell: CGFloat = 12
    static let cellGap: CGFloat = 16
    static let stackGap: CGFloat = 4
}

enum Strings {
    static let aboutSwiftLeeds = """
    Adam Rush founded SwiftLeeds in 2019, born from over ten years of experience attending conferences. The inspiration was bringing a modern, inclusive conference in the North of the UK to be more accessible for all.
    
    SwiftLeeds is now run with over ten community volunteers building the website, iOS applications and making sure we cover all the bases on the day. SwiftLeeds is entirely non-profit, and the funds make sure we can deliver the best experience possible.
    
    In-person conferences are the best way to meet like-minded people who enjoy building apps with Swift. You can also learn from the best people in the industry and chat about all things Swift.
    """
    static let aboutContributor = """
 SwiftLeeds is a conference for the community, by the community. Here's the people who helped to bring you the conference this year.
 """
}

enum Assets {
    enum Image {
        static let swiftLeedsIcon = "SwiftLeedsIcon"
        static let playhouseImage = "LeedsPlayhouse"
        static let swiftLeedsIconNoShadow = "SwiftLeedsNoShadow"
    }
}
