//
//  AdClient.swift
//  Drop
//
//  Created by Loïc Saillant on 28/05/2024.
//

import UIKit

protocol AdClient {
    var adUnit: String { get }
    var adIndexes: Set<Int> { get }
    
    init(userInfo: SessionUserInformation)
    
    func getAdView(for index: Int) -> UIView
    func getAd(for index: Int) -> Ad?
    func electAd(for index: Int)
    func load(with surroundingIds: [String])
    func reset()
}

protocol Ad {
    var adUnit: String { get }
    var index: Int? { get set }
    var type: AdType { get }
    var price: Double { get }
}

enum AdType: StringLiteralType {
    case native, mrec
}
