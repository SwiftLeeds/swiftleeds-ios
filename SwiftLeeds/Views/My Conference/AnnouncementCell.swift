//
//  AnnouncementCell.swift.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 25/06/2022.
//

import SwiftUI

struct AnnouncementCell: View {
    @Environment(\.sizeCategory) var sizeCategory

    let label: String
    let value: String
    let valueIcon: String
    let gradientColors: [Color]

    var body: some View {
        HStack {
            Text(label)
                .font(.headline.weight(.bold))

            Spacer()

            sizeAwareStack {
                Image(systemName: valueIcon)
                    .font(.title.weight(.semibold))
                Text(value)
                    .font(.subheadline.weight(.semibold))
            }
        }
        .foregroundColor(.white)
        .padding(Padding.cell)
        .frame(minHeight: Constants.cellMinimumHeight)
        .background {
            RoundedRectangle(cornerRadius: Constants.cellRadius)
                .fill(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .topTrailing))
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label). \(value)")
    }


    // When the text is huge, stack vertically instead to avoid compressing the leading text
    @ViewBuilder
    func sizeAwareStack<Content: View>(@ViewBuilder content: () -> (Content)) -> some View {
        if sizeCategory > .accessibilityLarge {
            VStack {
                content()
            }
        } else {
            HStack {
                content()
            }
        }
    }
}

struct AnnouncementCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: Padding.cellGap) {
            AnnouncementCell(label: "Leeds", value: "26℃", valueIcon: "cloud.sun.fill", gradientColors: [.weatherGradientStart, .weatherGradientEnd])
                .previewDisplayName("Weather")
            
            AnnouncementCell(label: "Get your ticket now", value: "69 days", valueIcon: "calendar.circle", gradientColors: [.buyTicketGradientStart, .buyTicketGradientEnd])
                .previewDisplayName("Buy Ticket")
        }
        .padding(20)
    }
}
