//
//  NativeAdClient.swift
//  Drop
//
//  Created by Loïc Saillant on 28/05/2024.
//

import Foundation
import AppLovinSDK
import AppHarbrSDK

final class NativeAdClient: NSObject, AdClient {
    
    // MARK: - data
    
    //properties
    let adUnit: String = AdConfig.nativeAdUnit
    
    private var availableAd: NativeAd?
    private var displayedAds: [NativeAd] = []
    var adIndexes = Set<Int>()
    
    private var isLoading = false
    private var retryAttempt = 0
    private let maxRetryAttempt = 5
    
    private lazy var adLoader: MANativeAdLoader = {
        let adLoader = AdInitializer.nativeAdLoader
        adLoader.setLocalExtraParameterForKey("google_max_ad_content_rating", value: "T")
        adLoader.setLocalExtraParameterForKey("google_native_ad_view_tag", value: AdConfig.gadNativeAdViewTag)
        setBigoParameters(for: adLoader)
        adLoader.nativeAdDelegate = self
        adLoader.revenueDelegate = self
        return adLoader
    }()
    
    private let userInfo: SessionUserInformation?
    
    // MARK: - Init
    
    init(userInfo: SessionUserInformation) {
        self.userInfo = userInfo
    }
            
    // MARK: - instance methods
    
    func getAd(for index: Int) -> Ad? {
        guard adIndexes.contains(index) || availableAd != nil else { return nil }
        return getNativeAd(at: index)
    }
    
    func electAd(for index: Int) {
        adIndexes.insert(index)
    }
    
    func getAdView(for index: Int) -> UIView {
        let nativeAdView = NativeAdView(frame: CGRect.zero)
        if let ad = getNativeAd(at: index) {
            adLoader.renderNativeAdView(nativeAdView, with: ad.ad)
            nativeAdView.prepare(for: ad.ad)
        }
        return nativeAdView
    }
    
    func reset() {
        displayedAds.forEach { adLoader.destroy($0.ad) }
        displayedAds = []
    }
    
    private func getNativeAd(at index: Int) -> NativeAd? {
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
        guard !isLoading, availableAd == nil
        else { return }
        print("🧙🏻‍♂️ LOAD")
        isLoading = true
        adLoader.setLocalExtraParameterForKey("google_neighbouring_content_url_strings", value: surroundingIds)
        adLoader.loadAd()
    }
    
    // MARK: - Private
    
    private func setBigoParameters(for adLoader: MANativeAdLoader) {
        guard let userInfo else { return }
        if let age = userInfo.age {
            adLoader.setLocalExtraParameterForKey("bigoads_age", value: "\(age)")
        }
        if let gender = userInfo.gender {
            adLoader.setLocalExtraParameterForKey("bigoads_gender", value: "\(gender)")
        }
        if let activatedTime = userInfo.activatedTime {
            adLoader.setLocalExtraParameterForKey("bigoads_activated_time", value: "\(activatedTime)")
        }
    }
}

// MARK: - MANativeAdDelegate

extension NativeAdClient: MANativeAdDelegate {
    
    func didLoadNativeAd(_ nativeAdView: MANativeAdView?, for ad: MAAd) {
        print("🧙🏻‍♂️ didLoadNativeAd")
        if AH.shouldBlock(nativeAd: ad, using: .max, unitId: ad.adUnitIdentifier).adStateResult == .blocked {
//            AdAnalytics.adDisplayBlocked.
            finishLoading()
            load()
        } else {
//            sendAnalytics(ad)
            availableAd = NativeAd(adUnit: adUnit, ad: ad)
            finishLoading()
        }
    }
    
    func didClickNativeAd(_ ad: MAAd) {

    }
    
    func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        print("😜😜😜 didFailToLoad :) \(error) waterfall=\(error.waterfall)")
        restartLoad()
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
}

// MARK: - MAAdRevenueDelegate

extension NativeAdClient: MAAdRevenueDelegate {
    
    func didPayRevenue(for ad: MAAd) {
        
    }
}
