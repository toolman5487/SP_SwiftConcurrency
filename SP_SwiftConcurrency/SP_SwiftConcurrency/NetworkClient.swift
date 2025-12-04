//
//  NetworkClient.swift
//  SP_SwiftConcurrency
//
//  Created by NeferUser on 2025/12/02.
//

import Foundation

enum NetworkError: LocalizedError, Sendable {
    case invalidResponse
    case httpStatus(Int)
    case decoding(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response."
        case .httpStatus(let code):
            return "Request failed with status code \(code)."
        case .decoding(let message):
            return "Decoding error: \(message)"
        }
    }
}

protocol NetworkClientProtocol: Sendable {
    func request<T: Decodable>(_ request: URLRequest, as type: T.Type) async throws -> T
}

final class NetworkClient: NetworkClientProtocol, @unchecked Sendable {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T: Decodable>(_ request: URLRequest, as type: T.Type) async throws -> T {
        var req = request
        if req.httpMethod == nil {
            req.httpMethod = "GET"
        }

        if req.value(forHTTPHeaderField: "Accept") == nil {
            req.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        if req.value(forHTTPHeaderField: "User-Agent") == nil {
            req.setValue("SP_SwiftConcurrency/1.0 (iOS)", forHTTPHeaderField: "User-Agent")
        }
        
        let (data, response) = try await session.data(for: req)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpStatus(httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(error.localizedDescription)
        }
    }
}


