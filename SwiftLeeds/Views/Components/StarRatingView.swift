//
//  StarRatingView.swift
//  SwiftLeeds
//
//  Created by Muralidharan Kathiresan on 09/09/25.
//

import SwiftUI

struct StarRatingView: View {
    let rating: Double
    let maxRating: Int
    let isInteractive: Bool
    let starSize: CGFloat
    let onRatingChanged: ((Int) -> Void)?
    
    @State private var currentRating: Int
    
    init(
        rating: Double,
        maxRating: Int = 5,
        isInteractive: Bool = false,
        starSize: CGFloat = 20,
        onRatingChanged: ((Int) -> Void)? = nil
    ) {
        self.rating = rating
        self.maxRating = maxRating
        self.isInteractive = isInteractive
        self.starSize = starSize
        self.onRatingChanged = onRatingChanged
        self._currentRating = State(initialValue: Int(rating))
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { index in
                Button(action: {
                    if isInteractive {
                        currentRating = index
                        onRatingChanged?(index)
                    }
                }) {
                    Image(systemName: starImage(for: index))
                        .font(.system(size: starSize, weight: .medium))
                        .foregroundColor(starColor(for: index))
                }
                .disabled(!isInteractive)
                .buttonStyle(.plain)
            }
        }
    }
    
    private func starImage(for index: Int) -> String {
        let adjustedRating = isInteractive ? Double(currentRating) : rating
        
        if Double(index) <= adjustedRating {
            return "star.fill"
        } else if Double(index) - 0.5 <= adjustedRating {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
    
    private func starColor(for index: Int) -> Color {
        let adjustedRating = isInteractive ? Double(currentRating) : rating
        
        if Double(index) <= adjustedRating {
            return .accent
        } else if Double(index) - 0.5 <= adjustedRating {
            return .accent
        } else {
            return .cellBorder
        }
    }
}

struct StarRatingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            StarRatingView(rating: 4.5)
                .previewDisplayName("Display Rating")
            
            StarRatingView(rating: 3.0, isInteractive: true) { _ in
                // Rating changed
            }
            .previewDisplayName("Interactive Rating")
            
            StarRatingView(rating: 4.8, starSize: 24)
                .previewDisplayName("Large Stars")
        }
        .padding()
    }
}
