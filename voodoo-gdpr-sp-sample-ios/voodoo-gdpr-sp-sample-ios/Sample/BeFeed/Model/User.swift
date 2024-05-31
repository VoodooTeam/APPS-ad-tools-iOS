//
//  User.swift
//  voodoo-gdpr-sp-sample-ios
//
//  Created by Loïc Saillant on 30/05/2024.
//

import Foundation

struct User: Identifiable, Codable {
    
    typealias ID = String
    
    let id: ID
    let createdAt: Date
    let updatedAt: Date
    let phoneNumber: String
    let username: String?
    var photo: PhotoSource
    var thumbnail: PhotoSource?
    
    var displayName: String {
        username ?? phoneNumber
    }
}

extension User: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(phoneNumber)
        hasher.combine(username)
        hasher.combine(photo)
        hasher.combine(thumbnail)
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id &&
        lhs.phoneNumber == rhs.phoneNumber &&
        lhs.username == rhs.username &&
        lhs.photo == rhs.photo &&
        lhs.thumbnail == rhs.thumbnail
    }
}

extension User: Comparable {
    static func < (lhs: User, rhs: User) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
}

// MARK: - Mocks

extension User {
    
    static var voodoo: User {
        User(id: "-1",
             createdAt: Date(),
             updatedAt: Date(),
             phoneNumber: "",
             username: "BeTeam",
             photo: .asset("logo"),
             thumbnail: nil)
    }
}

enum UserModelError: Error {
    case parsingFromDtoFailedIncorrectUrl(String)
}
