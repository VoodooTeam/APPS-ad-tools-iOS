//
//  Media.swift
//  voodoo-gdpr-sp-sample-ios
//
//  Created by Loïc Saillant on 30/05/2024.
//

import Foundation

struct Media: Codable, Identifiable {

    typealias ID = String
    
    let id: String
    let createdAt: Date
    var updatedAt: Date
    var content: MediaContent
    let author: User
    var state: State
    var isUnseen: Bool = false
    
    var isForOnboardingAndEmpty: Bool { id == "-1" }
    
    enum State: Codable, Equatable, Hashable {
        case fetching
        case sending
        case synced(at: Date)
        case failed
        
        var isDraft: Bool {
            switch self {
            case .sending, .failed, .fetching: true
            case .synced: false
            }
        }
    }
}

extension Media: Equatable {
    static func == (lhs: Media, rhs: Media) -> Bool {
        return lhs.id == rhs.id &&
        lhs.createdAt == rhs.createdAt &&
        lhs.updatedAt == rhs.updatedAt &&
        lhs.content == rhs.content &&
        lhs.author.id == rhs.author.id &&
        lhs.state == rhs.state &&
        lhs.isUnseen == rhs.isUnseen
    }
}

extension Media: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(createdAt)
        hasher.combine(updatedAt)
        hasher.combine(state)
    }
    
}

extension Media: Comparable {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.updatedAt > rhs.updatedAt
    }
}
