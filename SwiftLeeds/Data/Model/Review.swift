//
//  Review.swift
//  SwiftLeeds
//
//  Created by Muralidharan Kathiresan on 09/09/25.
//

import Foundation

struct Review: Codable, Identifiable {
    let id: UUID
    let userName: String
    let userInitials: String
    let rating: Int
    let comment: String
    let date: Date
    let isCurrentUser: Bool
    
    init(id: UUID = UUID(),
         userName: String?,
         rating: Int,
         comment: String,
         date: Date = Date(),
         isCurrentUser: Bool = false) {
        self.id = id
        
        if let userName = userName,
            !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.userName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
            self.userInitials = Review.generateInitials(from: userName)
        } else {
            self.userName = "Anonymous"
            self.userInitials = "AA"
        }
        
        self.rating = rating
        self.comment = comment
        self.date = date
        self.isCurrentUser = isCurrentUser
    }
    
    private static func generateInitials(from name: String) -> String {
        let components = name.trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        if components.isEmpty {
            return "AA"
        } else if components.count == 1 {
            return String(components[0].prefix(2)).uppercased()
        } else {
            let firstInitial = String(components[0].prefix(1))
            let lastInitial = String(components[components.count - 1].prefix(1))
            return "\(firstInitial)\(lastInitial)".uppercased()
        }
    }
}

struct RatingSummary {
    let averageRating: Double
    let totalRatings: Int
    let reviews: [Review]
    
    init(reviews: [Review]) {
        self.reviews = reviews
        self.totalRatings = reviews.count
        self.averageRating = reviews.isEmpty ? 0.0 : Double(reviews.map { $0.rating }.reduce(0, +)) / Double(reviews.count)
    }
}

extension Review {
    static let service = ReviewService()
    
    // UserDefaults key for tracking reviewed speakers
    private static let reviewedSpeakersKey = "ReviewedSpeakers"
    
    /// Load reviews for a specific speaker
    static func loadReviews(for speakerId: String) async throws -> [Review] {
        return try await service.fetchReviews(for: speakerId)
    }
    
    /// Submit a new review for a specific speaker
    static func submitReview(_ review: Review, for speakerId: String) async throws -> Review {
        // Mark this speaker as reviewed
        markSpeakerAsReviewed(speakerId)
        return try await service.submitReview(review, for: speakerId)
    }
    
    /// Check if the current user has already reviewed this speaker
    static func hasUserReviewed(speakerId: String) -> Bool {
        let reviewedSpeakers = UserDefaults.standard.array(forKey: reviewedSpeakersKey) as? [String] ?? []
        return reviewedSpeakers.contains(speakerId)
    }
    
    /// Mark a speaker as reviewed by the current user
    private static func markSpeakerAsReviewed(_ speakerId: String) {
        var reviewedSpeakers = UserDefaults.standard.array(forKey: reviewedSpeakersKey) as? [String] ?? []
        if !reviewedSpeakers.contains(speakerId) {
            reviewedSpeakers.append(speakerId)
            UserDefaults.standard.set(reviewedSpeakers, forKey: reviewedSpeakersKey)
        }
    }
    
    /// Get the user's review ID for a specific speaker (if exists)
    static func getUserReviewId(for speakerId: String) -> String? {
        return UserDefaults.standard.string(forKey: "UserReview_\(speakerId)")
    }
    
    /// Save the user's review ID for a specific speaker
    static func saveUserReviewId(_ reviewId: String, for speakerId: String) {
        UserDefaults.standard.set(reviewId, forKey: "UserReview_\(speakerId)")
    }
}
