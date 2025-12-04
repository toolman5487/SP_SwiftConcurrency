//
//  SPViewModel.swift
//  SP_SwiftConcurrency
//
//  Created by NeferUser on 2025/11/17.
//

import Foundation

@MainActor
final class SPViewModel {
    
    var user: User?
    var isLoading: Bool = false
    var errorMessage: String?
    
    private let service: RandomUserServiceProtocol
    
    init(service: RandomUserServiceProtocol = RandomUserService.shared) {
        self.service = service
    }
    
    func loadUser() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedUser = try await service.fetchUser()
            try Task.checkCancellation()
            self.user = fetchedUser
        } catch is CancellationError {
            return
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func formattedEmailInfo() -> String? {
        guard let user = user else { return nil }
        return """
        \(user.email)
        Username: \(user.login.username)
        """
    }

    func formattedPhoneInfo() -> String? {
        guard let user = user else { return nil }
        return """
        Phone: \(user.phone)
        Cell: \(user.cell)
        """
    }
    
    func loadUsers() async throws -> [User] {
        return try await service.fetchUsers(count: 10)
    }
}
