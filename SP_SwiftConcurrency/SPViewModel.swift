//
//  SPViewModel.swift
//  SP_SwiftConcurrency
//
//  Created by NeferUser on 2025/11/17.
//

import Foundation

@MainActor
final class SPViewModel {
    
    private let service: RandomUserServiceProtocol
    
    init(service: RandomUserServiceProtocol = RandomUserService.shared) {
        self.service = service
    }
    
    func loadUser() async throws -> User {
        return try await service.fetchUser()
    }
    
    func loadUsers() async throws -> [User]{
        return try await service.fetchUsers(count: 10)
    }
}
