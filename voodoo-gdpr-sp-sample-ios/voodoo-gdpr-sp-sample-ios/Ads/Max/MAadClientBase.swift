//
//  MAadClientBase.swift
//  Drop
//
//  Created by Gautier Gedoux on 31/05/2024.
//

import Foundation
import AppLovinSDK
import AppHarbrSDK

class MAadClientBase: NSObject {
    
    // MARK: - data
    
    //properties
    var availableAd: MAXAd?
    var displayedAds: [MAXAd] = []
    var adIndexes = Set<Int>()
    
    var isLoading = false
    var retryAttempt = 0
    let maxRetryAttempt = 5
    
    let userInfo: SessionUserInformation?
    
    // MARK: - Init
    
    init(userInfo: SessionUserInformation) {
        self.userInfo = userInfo
    }
            
    // MARK: - instance methods
    
    func getAd(for index: Int) -> Ad? {
        guard adIndexes.contains(index) || availableAd != nil else { return nil }
        return getCustomAd(at: index)
    }
    
    func electAd(for index: Int) {
        adIndexes.insert(index)
    }
    
    func getCustomAd(at index: Int) -> MAXAd? {
        if let displayedAd = displayedAds.first(where: { $0.index == index }) {
            return displayedAd
        }
        
        if let newAd = availableAd {
            newAd.index = index
            displayedAds.append(newAd)
            availableAd = nil
        } else if adIndexes.contains(index), let oldAd = displayedAds.first {
            oldAd.index = index
            return oldAd
        }
        return displayedAds.last
    }
        
    func load(with surroundingIds: [String] = []) {
        //to be implemented by subclasses
    }
    
    func finishLoading() {
        isLoading = false
        retryAttempt = 0
    }
    
    func restartLoad() {
        isLoading = false
        guard retryAttempt < maxRetryAttempt else { return }
        retryAttempt += 1
        let delaySec = pow(2.0, min(6.0, Double(retryAttempt)))
        DispatchQueue.main.asyncAfter(deadline: .now() + delaySec) { [weak self] in
            self?.load()
        }
    }    
    
    func adLoadingFailed(for adUnitIdentifier: String, with error: MAError) {
        AdAnalytics.adLoadingFailed.send(params: [
            "adUnitIdentifier": adUnitIdentifier,
            "errorCode": error.code.rawValue,
            "errorMessage": error.message,
            "cohortIdMax": error.waterfall?.testName ?? ""
        ])
        restartLoad()
    }
    
    func getMAadParameters(ad: MAAd) -> [String: Any] {
        return [
            "adType": ad.format.label,
            "adUnitIdentifier": ad.adUnitIdentifier,
            "adNetwork": ad.networkName,
            "adCreativeId": ad.creativeIdentifier,
            "adReviewCreativeId": ad.adReviewCreativeIdentifier,
            "placement": ad.placement,
            "cohortIdMax": ad.waterfall.testName,
            "revenuePrecision": ad.revenuePrecision,
            "latency": ad.requestLatency,
            "revenue": ad.revenue,
            "revenueUSD": ad.revenue,
            "revenueType": "ads",
            "currency": "USD",
            "revenueName": ad.format.label
        ]
    }
}

// MARK: - MAAdRevenueDelegate

extension MAadClientBase: MAAdRevenueDelegate {
    
    func didPayRevenue(for ad: MAAd) {
        AdAnalytics.adWatched.send(params: getMAadParameters(ad: ad))
    }
}