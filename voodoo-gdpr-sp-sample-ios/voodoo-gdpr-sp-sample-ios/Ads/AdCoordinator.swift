//
//  AdCoordinator.swift
//  voodoo-gdpr-sp-sample-ios
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
    
    var firstAdLoadedCallback: (() -> Void)?
    
    // MARK: - init
    
    func initWith(clients: [AdClient]) {
        clients.forEach { self.clients[$0.adUnit] = $0 }
        reload()
    }
    
    // MARK: - instance methods
    
    func reload() {
        for var client in clients.values {
            client.adAvailableCallback = { [weak self] in self?.newAdLoaded() }
        }
        reset()
        load()
    }
    
    func getAdView(for index: Int) -> UIView {
        for client in clients.values {
            guard client.adIndexes.contains(index) else { continue }
            return client.getAdView(for: index)
        }
        return UIView()
    }
    
    func shouldDisplayFooterAd(forDataSize dataSize: Int) -> Bool {
        guard dataSize > 0 && dataSize <= AdConfig.interval else { return false }
        return AdCoordinator.shared.isAdAvailable(for: dataSize, isLastIndex: true)
    }
    
    func isAdAvailable(for index: Int, isLastIndex: Bool = false, surroundingIds: [String] = []) -> Bool {
        load(with: surroundingIds)
        guard index > currentBiggestIndex + AdConfig.interval ||
                isLastIndex && currentBiggestIndex < 0  && index < AdConfig.interval else { return false }
        
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
    
    // MARK: - private methods
    
    private func reset() {
        adIndexes = Set<Int>()
        clients.values.forEach { $0.reset() }
        currentBiggestIndex = -1
    }
    
    private func load(with surroundingIds: [String] = []) {
        clients.values.forEach { $0.load(with: surroundingIds) }
    }
    
    private func newAdLoaded() {
        firstAdLoadedCallback?()
    }
}
