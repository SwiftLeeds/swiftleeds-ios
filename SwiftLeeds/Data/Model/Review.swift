//
//  Review.swift
//  SwiftLeeds
//
//  Created by Muralidharan Kathiresan on 09/09/25.
//

import Foundation

// MARK: - Review Model
struct Review: Codable, Identifiable {
    let id: UUID
    let userName: String
    let userInitials: String
    let rating: Int
    let comment: String
    let date: Date
    let isCurrentUser: Bool
    
    init(id: UUID = UUID(),
         userName: String,
         userInitials: String,
         rating: Int,
         comment: String,
         date: Date = Date(),
         isCurrentUser: Bool = false) {
        self.id = id
        self.userName = userName
        self.userInitials = userInitials
        self.rating = rating
        self.comment = comment
        self.date = date
        self.isCurrentUser = isCurrentUser
    }
}

// MARK: - Rating Summary
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

// MARK: - Static Data
extension Review {
    static let sampleReviews: [Review] = [
        Review(
            userName: "Sarah Mitchell",
            userInitials: "SM",
            rating: 5,
            comment: "Outstanding talk! The examples were incredibly practical and I immediately implemented custom property wrappers in my project. Donny's teaching style is excellent.",
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
        ),
        Review(
            userName: "James Rodriguez",
            userInitials: "JR", 
            rating: 4,
            comment: "Great content and well-structured presentation. The testing part was particularly valuable. Would have loved a bit more advanced examples.",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        ),
        Review(
            userName: "Emily Chen",
            userInitials: "EC",
            rating: 5,
            comment: "Mind-blowing! I never fully understood property wrappers until this talk. The live coding examples were perfect.",
            date: Calendar.current.date(byAdding: .hour, value: -6, to: Date()) ?? Date()
        ),
        Review(
            userName: "Alex Thompson",
            userInitials: "AT",
            rating: 4,
            comment: "Solid talk with good practical advice. The unit testing section was exactly what I needed for my team.",
            date: Calendar.current.date(byAdding: .hour, value: -3, to: Date()) ?? Date()
        ),
        Review(
            userName: "Maria Santos",
            userInitials: "MS",
            rating: 5,
            comment: "Fantastic presentation! Clear explanations and the Q&A session was very helpful. Definitely recommend.",
            date: Calendar.current.date(byAdding: .hour, value: -1, to: Date()) ?? Date()
        )
    ]
}
