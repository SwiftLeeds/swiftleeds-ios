//
//  TalkRatingView.swift
//  SwiftLeeds
//
//  Created by Muralidharan Kathiresan on 09/09/25.
//

import SwiftUI

struct TalkRatingView: View {
    private let presentation: Presentation
    
    @State private var ratingSummary: RatingSummary?
    @State private var userRating: Int = 0
    @State private var userComment: String = ""
    @State private var userName: String = ""
    @State private var userSubmittedReview: Review? = nil
    @State private var hasUserAlreadyReviewed: Bool = false
    @State private var showingSubmittedAlert: Bool = false
    @State private var isLoading: Bool = true
    @State private var errorMessage: String? = nil
    @FocusState private var isCommentFieldFocused: Bool
    @FocusState private var isUserNameFieldFocused: Bool
    
    // Get the primary speaker ID for this presentation
    private var speakerId: String? {
        presentation.speakers.first?.id.uuidString
    }
    
    init(presentation: Presentation) {
        self.presentation = presentation
    }
    
    var body: some View {
        SwiftLeedsContainer {
            ScrollView {
                content
            }
        }
        .navigationTitle("Rate Talk")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadReviews()
        }
        .alert("Review Submitted",
               isPresented: $showingSubmittedAlert) {
            Button("OK") { }
        } message: {
            Text("Thank you for your feedback!")
        }
        .alert("Error",
               isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private var content: some View {
        VStack(spacing: Padding.stackGap) {
            headerView
            
            if isLoading {
                loadingView
            } else if let ratingSummary = ratingSummary {
                VStack(spacing: Padding.screen) {
                    if hasUserAlreadyReviewed {
                        alreadyReviewedSection
                    } else {
                        userRatingSection
                    }
                    
                    reviewsSection(ratingSummary: ratingSummary)
                }
                .padding(Padding.screen)
            } else {
                emptyReviewsView
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading reviews...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 50)
    }
    
    private var emptyReviewsView: some View {
        VStack(spacing: Padding.screen) {
            if hasUserAlreadyReviewed {
                alreadyReviewedSection
            } else {
                userRatingSection
            }
            
            VStack(spacing: 16) {
                Image(systemName: "star.circle")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
                
                Text("No reviews yet")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(hasUserAlreadyReviewed ? "Thank you for your review!" : "Be the first to rate this talk!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 50)
        }
        .padding(Padding.screen)
    }
    
    private var alreadyReviewedSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Review Submitted")
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    Text("Thank you for rating this talk!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(Padding.cell)
        .background(
            RoundedRectangle(cornerRadius: Constants.cellRadius)
                .fill(Color.green.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Constants.cellRadius)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
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
            Text("Add Your Rating")
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
                    TextField("Your name (optional)", text: $userName)
                        .textFieldStyle(.roundedBorder)
                        .focused($isUserNameFieldFocused)
                    
                    Text("Leave empty to post as 'Anonymous'")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
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
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("SUBMIT REVIEW")
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
    
    private func reviewsSection(ratingSummary: RatingSummary) -> some View {
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
                ForEach(otherReviews(from: ratingSummary).sorted { $0.date > $1.date }) { review in
                    reviewCell(review, isUserReview: false)
                }
            }
        }
    }
    
    private func otherReviews(from ratingSummary: RatingSummary) -> [Review] {
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
    }
    
    private func submitReview() {
        guard let speakerId = speakerId else {
            errorMessage = "Unable to determine speaker for this presentation"
            return
        }
        
        // Check if user has already reviewed this speaker
        if Review.hasUserReviewed(speakerId: speakerId) {
            errorMessage = "You have already reviewed this speaker"
            return
        }
        
        Task {
            do {
                // Create new review with optional username
                let newReview = Review(
                    userName: userName.isEmpty ? nil : userName,
                    rating: userRating,
                    comment: userComment,
                    date: Date(),
                    isCurrentUser: true
                )
                
                // Submit new review
                let submittedReview = try await Review.submitReview(newReview, for: speakerId)
                
                // Save the user's review ID for tracking
                Review.saveUserReviewId(submittedReview.id.uuidString, for: speakerId)
                
                // Update local state
                await MainActor.run {
                    if let currentSummary = ratingSummary {
                        var updatedReviews = currentSummary.reviews
                        updatedReviews.append(submittedReview)
                        ratingSummary = RatingSummary(reviews: updatedReviews)
                    } else {
                        ratingSummary = RatingSummary(reviews: [submittedReview])
                    }
                    
                    // Update UI state
                    hasUserAlreadyReviewed = true
                    userRating = 0
                    userComment = ""
                    userName = ""
                    isCommentFieldFocused = false
                    isUserNameFieldFocused = false
                    showingSubmittedAlert = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to submit review: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func loadReviews() async {
        guard let speakerId = speakerId else {
            await MainActor.run {
                errorMessage = "Unable to determine speaker for this presentation"
                isLoading = false
            }
            return
        }
        
        
        // Check if user has already reviewed this speaker
        let hasReviewed = Review.hasUserReviewed(speakerId: speakerId)
        
        do {
            let reviews = try await Review.loadReviews(for: speakerId)
            await MainActor.run {
                ratingSummary = RatingSummary(reviews: reviews)
                hasUserAlreadyReviewed = hasReviewed
                isLoading = false
            }
        } catch {
            await MainActor.run {
                // Create empty rating summary if no reviews found
                ratingSummary = RatingSummary(reviews: [])
                hasUserAlreadyReviewed = hasReviewed
                isLoading = false
            }
        }
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
