//
//  ReviewService.swift
//  SwiftLeeds
//
//  Created by Muralidharan Kathiresan on 10/09/25.
//

import Foundation

protocol ReviewServiceProtocol {
    func fetchReviews(for speakerId: String) async throws -> [Review]
    func submitReview(_ review: Review, for speakerId: String) async throws -> Review
}

class ReviewService: ReviewServiceProtocol {
    private let session: URLSession
    private let isLocalMode: Bool
    
    init(session: URLSession = .shared, isLocalMode: Bool = true) {
        self.session = session
        self.isLocalMode = isLocalMode
    }
    
    
    // MARK: - Fetch Reviews
    func fetchReviews(for speakerId: String) async throws -> [Review] {
        if isLocalMode {
            return try await fetchLocalReviews(for: speakerId)
        } else {
            return try await fetchRemoteReviews(for: speakerId)
        }
    }
    
    // MARK: - Submit Review
    func submitReview(_ review: Review, for speakerId: String) async throws -> Review {
        if isLocalMode {
            // In local mode, we'll simulate the submission and return the review
            // This can be extended to write to local storage if needed
            return review
        } else {
            return try await submitRemoteReview(review, for: speakerId)
        }
    }
    
    // MARK: - Private Methods - Local Mode
    private func fetchLocalReviews(for speakerId: String) async throws -> [Review] {
        guard let url = Bundle.main.url(forResource: speakerId, withExtension: "json") else {
            // No reviews file found for this speaker - return empty array
            return []
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode([Review].self, from: data)
    }
    
    // MARK: - Private Methods - Remote Mode (API)
    private func fetchRemoteReviews(for speakerId: String) async throws -> [Review] {
        // TODO: Replace with actual API endpoint once ready
        let urlString = "https://api.swiftleeds.co.uk/reviews/\(speakerId)"
        guard let url = URL(string: urlString) else {
            throw ReviewServiceError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ReviewServiceError.networkError
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode([Review].self, from: data)
    }
    
    private func submitRemoteReview(_ review: Review, for speakerId: String) async throws -> Review {
        // TODO: Replace with actual API endpoint once ready
        let urlString = "https://api.swiftleeds.co.uk/reviews/\(speakerId)"
        guard let url = URL(string: urlString) else {
            throw ReviewServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        request.httpBody = try encoder.encode(review)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw ReviewServiceError.submissionFailed
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode(Review.self, from: data)
    }
}

// MARK: - Review Service Errors
enum ReviewServiceError: Error, LocalizedError {
    case invalidURL
    case networkError
    case submissionFailed
    case jsonParsingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL for review service"
        case .networkError:
            return "Network error occurred while fetching reviews"
        case .submissionFailed:
            return "Failed to submit review"
        case .jsonParsingError:
            return "Failed to parse review data"
        }
    }
}
