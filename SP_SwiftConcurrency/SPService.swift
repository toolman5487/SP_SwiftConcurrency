//
//  SPService.swift
//  SP_SwiftConcurrency
//
//  Created by NeferUser on 2025/11/17.
//

import Foundation

enum RandomUserServiceError: LocalizedError {
    case invalidURL
    case emptyResults
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .emptyResults:
            return "No users found in response."
        }
    }
}

protocol RandomUserServiceProtocol: Sendable {
    func fetchUsers(count: Int) async throws -> [User]
    func fetchUser() async throws -> User
}

final class RandomUserService: RandomUserServiceProtocol {
    
    static let shared = RandomUserService()
    
    private let baseURL = URL(string: "https://randomuser.me")!
    private let client: NetworkClientProtocol
    
    init(client: NetworkClientProtocol = NetworkClient()) {
        self.client = client
    }
    
    func fetchUser() async throws -> User {
        let users = try await fetchUsers(count: 1)
        guard let first = users.first else {
            throw RandomUserServiceError.emptyResults
        }
        return first
    }
    
    func fetchUsers(count: Int = 1) async throws -> [User] {
        var components = URLComponents(
            url: baseURL.appendingPathComponent("api"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "results", value: String(count))
        ]
        
        guard let url = components?.url else {
            throw RandomUserServiceError.invalidURL
        }
        
        let request = URLRequest(url: url)
        
        let response: RandomUserResponse = try await client.request(
            request,
            as: RandomUserResponse.self
        )
        
        if response.results.isEmpty {
            throw RandomUserServiceError.emptyResults
        }
        
        return response.results
    }
}
