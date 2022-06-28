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
        .padding(.horizontal, 12)
        .padding(.vertical, 20)
        .foregroundColor(.white)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .topTrailing))
        }
    }
}

struct AnnouncementCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 8) {
            AnnouncementCell(label: "Leeds", value: "26℃", valueIcon: "cloud.sun.fill", gradientColors: [.weatherGradientStart, .weatherGradientEnd])
                .previewDisplayName("Weather")
            
            AnnouncementCell(label: "Get your ticket now", value: "69 days", valueIcon: "calendar.circle", gradientColors: [.buyTicketGradientStart, .buyTicketGradientEnd])
                .previewDisplayName("Buy Ticket")
        }
        .padding(20)
    }
}
