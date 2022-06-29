//
//  AnnouncementCell.swift.swift
//  SwiftLeeds
//
//  Created by Matthew Gallagher on 25/06/2022.
//

import SwiftUI

struct AnnouncementCell: View {
    let label: String
    let value: String
    let valueIcon: String
    let gradientColors: [Color]

    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.medium)
            Spacer()
            Image(systemName: valueIcon)
            Text(value)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(Padding.cell)
        .frame(minHeight: Constants.cellMinimumHeight)
        .background {
            RoundedRectangle(cornerRadius: Constants.cellRadius)
                .fill(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .topTrailing))
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
