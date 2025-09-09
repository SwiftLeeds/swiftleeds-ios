//
//  TalkRatingView.swift
//  SwiftLeeds
//
//  Created by Muralidharan Kathiresan on 09/09/25.
//

import SwiftUI

struct TalkRatingView: View {
    private let presentation: Presentation
    
    @State private var ratingSummary: RatingSummary
    @State private var userRating: Int = 0
    @State private var userComment: String = ""
    @State private var userSubmittedReview: Review? = nil
    @State private var isEditingExistingReview: Bool = false
    @State private var showingSubmittedAlert: Bool = false
    @FocusState private var isCommentFieldFocused: Bool
    
    init(presentation: Presentation) {
        self.presentation = presentation
        self._ratingSummary = State(initialValue: RatingSummary(reviews: Review.sampleReviews))
    }
    
    var body: some View {
        SwiftLeedsContainer {
            ScrollView {
                content
            }
        }
        .navigationTitle("Rate Talk")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Review Submitted",
               isPresented: $showingSubmittedAlert) {
            Button("OK") { }
        } message: {
            Text("Thank you for your feedback!")
        }
    }
    
    private var content: some View {
        VStack(spacing: Padding.stackGap) {
            headerView
            
            VStack(spacing: Padding.screen) {
                if userSubmittedReview == nil || isEditingExistingReview {
                    userRatingSection
                }
                
                reviewsSection
            }
            .padding(Padding.screen)
        }
    }
    
    private var headerView: some View {
        FancyHeaderView(
            title: presentation.title,
            foregroundImageURLs: presentation.speakers.compactMap { speaker in
                speaker.profileImage.isEmpty ? nil : URL(string: speaker.profileImage)
            }
        )
    }
    
    private var userRatingSection: some View {
        VStack(spacing: 16) {
            Text(isEditingExistingReview ? "Edit Your Rating" : "Add Rating")
                .font(.headline.weight(.semibold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(spacing: 16) {
                StarRatingView(
                    rating: Double(userRating),
                    isInteractive: true,
                    starSize: 32
                ) { newRating in
                    userRating = newRating
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Optional comment", text: $userComment, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                        .focused($isCommentFieldFocused)
                }
                
                Button(action: {
                    if userRating > 0 {
                        submitReview()
                    }
                }) {
                    HStack {
                        if isEditingExistingReview {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .semibold))
                        } else {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        
                        Text(buttonText)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(buttonBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Constants.cellRadius))
                }
                .disabled(userRating == 0)
                .animation(.easeInOut(duration: 0.2), value: userRating)
            }
        }
        .padding(Padding.cell)
        .background(
            RoundedRectangle(cornerRadius: Constants.cellRadius)
                .fill(Color.cellBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cellRadius)
                .stroke(Color.cellBorder, lineWidth: 1)
        )
        .onAppear {
            if let existingReview = userSubmittedReview, isEditingExistingReview {
                userRating = existingReview.rating
                userComment = existingReview.comment
            }
        }
    }
    
    private var buttonText: String {
        if userRating == 0 {
            return "SEND RATING"
        } else if isEditingExistingReview {
            return "EDIT RATING"
        } else {
            return "SEND RATING"
        }
    }
    
    private var buttonBackground: LinearGradient {
        if userRating == 0 {
            return LinearGradient(
                colors: [Color.secondary.opacity(0.3), Color.secondary.opacity(0.3)],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [.buyTicketGradientStart, .buyTicketGradientEnd],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    private var reviewsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("\(ratingSummary.totalRatings) Ratings")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 8) {
                    StarRatingView(rating: ratingSummary.averageRating, starSize: 16)
                    Text(String(format: "%.1f", ratingSummary.averageRating))
                        .font(.title2.weight(.bold))
                        .foregroundColor(.accent)
                }
            }
            
            LazyVStack(spacing: Padding.cellGap) {
                // Show user's review first if it exists
                if let userReview = userSubmittedReview {
                    reviewCell(userReview, isUserReview: true)
                }
                
                // Show other reviews (excluding user's review if it exists)
                ForEach(otherReviews.sorted { $0.date > $1.date }) { review in
                    reviewCell(review, isUserReview: false)
                }
            }
        }
    }
    
    private var otherReviews: [Review] {
        ratingSummary.reviews.filter { review in
            if let userReview = userSubmittedReview {
                return review.id != userReview.id
            }
            return true
        }
    }
    
    private func reviewCell(_ review: Review, isUserReview: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // User avatar
                Circle()
                    .fill(isUserReview ? Color.accent : Color.cellBorder)
                    .frame(width: 40, height: 40)
                    .overlay {
                        Text(review.userInitials)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(isUserReview ? .white : .primary)
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(isUserReview ? "You" : review.userName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(isUserReview ? "Now" : timeAgoString(from: review.date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if isUserReview {
                    Image(systemName: "pencil")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Star rating
            HStack {
                StarRatingView(
                    rating: Double(review.rating),
                    starSize: 18
                )
                Spacer()
            }
            
            // Comment
            if !review.comment.isEmpty {
                Text(review.comment)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(Padding.cell)
        .background(
            RoundedRectangle(cornerRadius: Constants.cellRadius)
                .fill(Color.cellBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cellRadius)
                .stroke(isUserReview ? Color.accent.opacity(0.3) : Color.cellBorder, lineWidth: 1)
        )
        .onTapGesture {
            if isUserReview {
                // Enable editing mode
                isEditingExistingReview = true
                userRating = review.rating
                userComment = review.comment
            }
        }
    }
    
    private func submitReview() {
        if isEditingExistingReview {
            // Update existing review
            if let existingReview = userSubmittedReview {
                let updatedReview = Review(
                    id: existingReview.id,
                    userName: "You",
                    userInitials: "ME",
                    rating: userRating,
                    comment: userComment,
                    date: Date(),
                    isCurrentUser: true
                )
                
                // Update in the main reviews list
                var updatedReviews = ratingSummary.reviews
                if let index = updatedReviews.firstIndex(where: { $0.id == existingReview.id }) {
                    updatedReviews[index] = updatedReview
                }
                
                // Update user's submitted review
                userSubmittedReview = updatedReview
                ratingSummary = RatingSummary(reviews: updatedReviews)
            }
        } else {
            // Create new review
            let newReview = Review(
                userName: "You",
                userInitials: "ME",
                rating: userRating,
                comment: userComment,
                date: Date(),
                isCurrentUser: true
            )
            
            // Add to rating summary
            var updatedReviews = ratingSummary.reviews
            updatedReviews.append(newReview)
            ratingSummary = RatingSummary(reviews: updatedReviews)
            
            // Set as user's submitted review
            userSubmittedReview = newReview
        }
        
        // Reset form state
        isEditingExistingReview = false
        userRating = 0
        userComment = ""
        isCommentFieldFocused = false
        showingSubmittedAlert = true
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct TalkRatingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TalkRatingView(presentation: Presentation.donnyWalls)
        }
        .navigationViewStyle(.stack)
    }
}
