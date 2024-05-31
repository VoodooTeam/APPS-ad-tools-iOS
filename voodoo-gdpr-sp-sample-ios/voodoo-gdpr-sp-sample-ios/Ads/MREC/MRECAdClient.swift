//
//  MRECAdClient.swift
//  Wizz
//
//  Created by Gautier Gedoux on 29/04/2022.
//  Copyright © 2022 VLBAPPS. All rights reserved.
//

import Foundation
import AppLovinSDK
import UIKit
import AppHarbrSDK
import DTBiOSSDK

final class MRECAdClient: NSObject, AdClient {
    // MARK: - data
    
    //properties
    let adUnit: String = AdConfig.mrecAdUnit
    
    private var availableAd: MRECAd?
    private var displayedAds: [MRECAd] = []
    var adIndexes = Set<Int>()
    
    private var isLoading = false
    private var retryAttempt = 0
    private let maxRetryAttempt = 5
    
    private var loadingView: MAAdView!
    
    private let userInfo: SessionUserInformation?
    
    // MARK: - Init
    
    init(userInfo: SessionUserInformation) {
        self.userInfo = userInfo
    }
    
    // MARK: - instance methods
    
    func getAd(for index: Int) -> Ad? {
        guard adIndexes.contains(index) || availableAd != nil else { return nil }
        return getMRECAd(at: index)
    }
    
    func electAd(for index: Int) {
        adIndexes.insert(index)
    }

    func getAdView(for index: Int) -> UIView {
        if let ad = getMRECAd(at: index) {
            return MRECAdView(mrecView: ad.adView)
        }
        return UIView()
    }
    
    func reset() {
        resetIndexedAd()
    }
    
    func getMRECAd(at index: Int) -> MRECAd? {
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
        guard !isLoading && availableAd == nil else { return }
        isLoading = true
        
        loadingView = MAAdView(adUnitIdentifier: AdConfig.mrecAdUnit, adFormat: MAAdFormat.mrec, sdk: AdInitializer.appLoSdk)
        loadingView.delegate = self
        loadingView.revenueDelegate = self
        loadingView.setExtraParameterForKey("allow_pause_auto_refresh_immediately", value: "true")
        loadingView.setLocalExtraParameterForKey("google_max_ad_content_rating", value: "T")
        loadingView.setExtraParameterForKey("allow_pause_auto_refresh_immediately", value: "true")
        loadingView.setLocalExtraParameterForKey("google_neighbouring_content_url_strings", value: surroundingIds)
        
        AH.addBanner(with: .max, adObject: loadingView, delegate: self)

        loadingView.stopAutoRefresh()
        let adLoader = DTBAdLoader()
        adLoader.setAdSizes([DTBAdSize(bannerAdSizeWithWidth: 300,
                             height: 250,
                                       andSlotUUID: AdConfig.amazonSlotID)!])
        adLoader.loadAd(self)
    }
    
    // MARK: - destroy
    
    private func resetAvailableAd() {
        availableAd = nil
    }
    
    private func resetIndexedAd() {
        adIndexes = Set<Int>()
    }

    // MARK: - Private
    
    private func setBigoParameters() {
        guard let userInfo, let loadingView else { return }
        if let age = userInfo.age {
            loadingView.setLocalExtraParameterForKey("bigoads_age", value: "\(age)")
        }
        if let gender = userInfo.gender {
            loadingView.setLocalExtraParameterForKey("bigoads_gender", value: "\(gender)")
        }
        if let activatedTime = userInfo.activatedTime {
            loadingView.setLocalExtraParameterForKey("bigoads_activated_time", value: "\(activatedTime)")
        }
    }
    
}

// MARK: - MANativeAdDelegate

extension MRECAdClient: MAAdViewAdDelegate {
    
    func didLoad(_ ad: MAAd) {
//        sendAnalytics(ad)
        
        finishLoading()
        resetAvailableAd()
        
        guard let loadingView = loadingView else { return }
        availableAd = MRECAd(adUnit: adUnit, ad: ad, adView: loadingView)
    }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        restartLoad()
    }

    func didClick(_ ad: MAAd) {
//        Analytics.adClicked(
//            adType: .storyAd,
//            adNetwork: ad.networkName,
//            adCreativeId: ad.creativeIdentifier,
//            adReviewCreativeId: ad.adReviewCreativeIdentifier,
//            adTestName: ad.waterfall.testName,
//            from: .swipe
//        )
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {}
    
    func didExpand(_ ad: MAAd) {}
    
    func didCollapse(_ ad: MAAd) {}
    
    func didDisplay(_ ad: MAAd) {
    }
    
    func didHide(_ ad: MAAd) {}
    
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

}

// MARK: - MAAdRevenueDelegate

extension MRECAdClient: MAAdRevenueDelegate {
    
    func didPayRevenue(for ad: MAAd) {}
}

//MARK: - AppHarbr
extension MRECAdClient: AppHarbrDelegate {
    func didAdBlocked(ad: NSObject?, unitId: String?, adForamt: AppHarbrSDK.AdFormat, reasons: [String]) {
        guard let maxAd = ad as? MAAd else { return }
//        AdAnalytics.adDisplayBlocked.send(params: )
        
        resetIndexedAd()
        resetAvailableAd()
        
        load()
    }
}

extension MRECAdClient: DTBAdCallback {
    func onSuccess(_ adResponse: DTBAdResponse!) {
        loadingView.setLocalExtraParameterForKey("amazon_ad_response", value: adResponse)
        loadingView.loadAd()
    }
    
    func onFailure(_ error: DTBAdError, dtbAdErrorInfo: DTBAdErrorInfo!) {
        loadingView.setLocalExtraParameterForKey("amazon_ad_error", value:dtbAdErrorInfo)
        loadingView.loadAd()
    }
}
