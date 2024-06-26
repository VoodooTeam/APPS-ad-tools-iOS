//
//  NativeMAadClient.swift
//  voodoo-gdpr-sp-sample-ios
//
//  Created by Loïc Saillant on 28/05/2024.
//

import Foundation
import AppLovinSDK
import AppHarbrSDK

final class NativeMAadClient: MAadClientBase, AdClient {
    
    // MARK: - data
    
    //properties
    private lazy var adLoader: MANativeAdLoader = {
        let adLoader = MANativeAdLoader(adUnitIdentifier: AdConfig.nativeAdUnit, sdk: ALSdk.shared())
        adLoader.setLocalExtraParameterForKey("google_max_ad_content_rating", value: "T")
        adLoader.setLocalExtraParameterForKey("google_native_ad_view_tag", value: AdConfig.gadNativeAdViewTag)
        setBigoParameters(for: adLoader)
        adLoader.nativeAdDelegate = self
        adLoader.revenueDelegate = self
        return adLoader
    }()
    
    // MARK: - instance methods
    
    func getAdView(for index: Int) -> UIView {
        let nativeAdView = NativeAdView(frame: CGRect.zero)
        if let ad = getCustomAd(at: index) as? NativeAd {
            adLoader.renderNativeAdView(nativeAdView, with: ad.ad)
            nativeAdView.prepare(for: ad.ad)
        }
        nativeAdView.layoutIfNeeded()
        return nativeAdView
    }
        
    override func load(with surroundingIds: [String] = []) {
        guard !isLoading, availableAd == nil else { return }
        isLoading = true
        AdAnalytics.adLoadingStarted.send(params: ["adUnitIdentifier": adUnit])
        adLoader.setLocalExtraParameterForKey("google_neighbouring_content_url_strings", value: getContentMappingUrls(for: surroundingIds))
        loadBackgroundQueue.async { [weak self] in self?.adLoader.loadAd() }
    }
    
    // MARK: - Private
    
    private func setBigoParameters(for adLoader: MANativeAdLoader) {
        if let age = userInfo?.age {
            adLoader.setLocalExtraParameterForKey("bigoads_age", value: "\(age)")
        }
        if let gender = userInfo?.gender {
            adLoader.setLocalExtraParameterForKey("bigoads_gender", value: "\(gender)")
        }
        if let activatedTime = userInfo?.activatedTime {
            adLoader.setLocalExtraParameterForKey("bigoads_activated_time", value: "\(activatedTime)")
        }
    }
    
    // MARK: - Destroy
    
    override func reset() {
        displayedAds.forEach { adLoader.destroy($0.ad) }
        super.reset()
    }
}

// MARK: - MANativeAdDelegate

extension NativeMAadClient: MANativeAdDelegate {
    
    func didLoadNativeAd(_ nativeAdView: MANativeAdView?, for ad: MAAd) {
        let adParams = getMAadParameters(ad: ad)
        finishLoading()

        if AH.shouldBlock(nativeAd: ad, using: .max, unitId: ad.adUnitIdentifier).adStateResult == .blocked {
            AdAnalytics.adDisplayBlocked.send(params: adParams)
            load()
        } else {
            AdAnalytics.adLoadingFinished.send(params: adParams)
            availableAd = NativeAd(adUnit: adUnit, ad: ad)
        }
    }
    
    func didClickNativeAd(_ ad: MAAd) {
        AdAnalytics.adClicked.send(params: getMAadParameters(ad: ad))
    }
    
    func didFailToLoadNativeAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        adLoadingFailed(for: adUnitIdentifier, with: error)
    }
}
