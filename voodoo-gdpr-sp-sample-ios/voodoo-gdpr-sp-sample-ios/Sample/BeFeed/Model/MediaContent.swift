//
//  MediaContent.swift
//  voodoo-gdpr-sp-sample-ios
//
//  Created by Loïc Saillant on 30/05/2024.
//

import Foundation

struct MediaContent: Codable, Hashable {
    let kind: Kind
    var source: PhotoSource
    let thumbnail: PhotoSource?
    let size: Size
    let duration: Int?
    
    init(kind: Kind = .photo, source: PhotoSource, thumbnail: PhotoSource?, size: Size, duration: Int? = nil) {
        self.kind = kind
        self.source = source
        self.thumbnail = thumbnail
        self.size = size
        self.duration = duration
    }
    
    enum Kind: Codable, Hashable {
        case photo
        case video
    }

    struct Size: Codable, Hashable {
        let height: Double
        let width: Double
        var ratio: Double { height / width }
    }
}

enum PhotoSource: Codable, Hashable {
    case url(URL)
    case data(Data)
    case none
    case asset(String) // for mocks only
    
    var url: URL? {
        switch self {
        case .url(let url):
            url
        default: 
            nil
        }
    }
}
