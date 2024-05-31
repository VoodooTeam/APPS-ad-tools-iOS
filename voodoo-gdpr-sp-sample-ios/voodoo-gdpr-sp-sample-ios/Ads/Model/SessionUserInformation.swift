//
//  BigoUserInformation.swift
//  Drop
//
//  Created by Loïc Saillant on 30/05/2024.
//

import Foundation

// Specific setup for Bigo Ads
// https://www.bigossp.com/guide/sdk/ios/mediation/maxAdapter
/// age - Session user age
/// gender - Session user gender
/// activatedTime - Set the timestamp of your app that the first time been activated

struct SessionUserInformation {
    
    enum Gender: String {
        case female = "1", male = "2"
    }
    
    let age: String?
    let gender: String?
    let activatedTime: String?
    
    init(age: String?, gender: Gender?, activatedTime: String?) {
        self.age = age
        self.gender = gender?.rawValue
        self.activatedTime = activatedTime
    }
    
    static let empty = SessionUserInformation(age: nil, gender: nil, activatedTime: nil)
}
