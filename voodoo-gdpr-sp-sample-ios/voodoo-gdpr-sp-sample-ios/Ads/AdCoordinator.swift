//
//  AdCoordinator.swift
//  Drop
//
//  Created by Gautier Gedoux on 29/05/2024.
//

import UIKit

final class AdCoordinator {
    
    // MARK: - data
    
    //singleton
    static let shared = AdCoordinator()
    
    //properties
    private var currentBiggestIndex: Int = -1
    
    var clients = [String: AdClient]()
    private var adIndexes = Set<Int>()
    
    var allAdIndexes: [Int] {
        return Array(adIndexes).sorted()
    }
    
    // MARK: - init
    
    func initWith(clients: [AdClient]) {
        clients.forEach { self.clients[$0.adUnit] = $0 }
    }
    
    // MARK: - instance methods
    
    func reset() {
        adIndexes = Set<Int>()
        clients.values.forEach { $0.reset() }
    }
    
    
    func getAdView(for index: Int) -> UIView {
        for client in clients.values {
            guard client.adIndexes.contains(index) else { continue }
            return client.getAdView(for: index)
        }
        return UIView()
    }
    
    func isAdAvailable(for index: Int, surroundingIds: [String]) -> Bool {
        load(with: surroundingIds)
        guard index > currentBiggestIndex + AdConfig.interval else { return false }
        
        let ads = clients.values.map { $0.getAd(for: index) }
        var electedAd: Ad?
        
        for ad in ads {
            guard let ad, electedAd == nil || electedAd!.price < ad.price else { continue }
            electedAd = ad
        }
        
        if let electedAd {
            clients[electedAd.adUnit]?.electAd(for: index)
            adIndexes.insert(index)
            currentBiggestIndex = max(index, currentBiggestIndex)
        }
        return electedAd != nil
    }
    
    func load(with surroundingIds: [String] = []) {
        clients.values.forEach { $0.load(with: surroundingIds) }
    }
}
