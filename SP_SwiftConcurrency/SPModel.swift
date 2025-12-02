//
//  SPModel.swift
//  SP_SwiftConcurrency
//
//  Created by NeferUser on 2025/11/17.
//

import Foundation

struct RandomUserResponse: Codable {
    let results: [User]
    let info: ResponseInfo
}

struct ResponseInfo: Codable {
    let seed: String
    let results: Int
    let page: Int
    let version: String
}

struct User: Codable, Identifiable {
    let gender: String
    let name: Name
    let location: Location
    let email: String
    let login: Login
    let dob: DateOfBirth
    let registered: Registered
    let phone: String
    let cell: String
    let picture: Picture
    let nat: String
    let userId: UserID?
    
    var id: String {
        login.uuid
    }
    
    enum CodingKeys: String, CodingKey {
        case gender, name, location, email, login, dob, registered, phone, cell, picture, nat
        case userId = "id"
    }
}

struct UserID: Codable {
    let name: String?
    let value: String?
}

struct Name: Codable {
    let title: String
    let first: String
    let last: String
    
    var fullName: String {
        "\(first) \(last)"
    }
}

struct Location: Codable {
    let street: Street
    let city: String
    let state: String
    let country: String
    let postcode: Postcode
    let coordinates: Coordinates
    let timezone: Timezone
    
    var fullAddress: String {
        "\(street.number) \(street.name), \(city), \(state) \(postcode.value), \(country)"
    }
}

struct Postcode: Codable {
    let value: String
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            value = String(intValue)
        } else {
            value = try container.decode(String.self)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

struct Street: Codable {
    let number: Int
    let name: String
}

struct Coordinates: Codable {
    let latitude: String
    let longitude: String
}

struct Timezone: Codable {
    let offset: String
    let description: String
}

struct Login: Codable {
    let uuid: String
    let username: String
    let password: String
    let salt: String
    let md5: String
    let sha1: String
    let sha256: String
}

struct DateOfBirth: Codable {
    let date: String
    let age: Int
}

struct Registered: Codable {
    let date: String
    let age: Int
}

struct Picture: Codable {
    let large: String
    let medium: String
    let thumbnail: String
}
