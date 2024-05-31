//
//  MRECMAadClient.swift
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

final class MRECMAadClient: MAadClientBase, AdClient {
    // MARK: - data
    
    //properties
    let adUnit: String = AdConfig.mrecAdUnit
    
    private var loadingView: MAAdView!
    
    private var didDisplay: Bool = false
    
    // MARK: - instance methods

    func getAdView(for index: Int) -> UIView {
        if let ad = getCustomAd(at: index) as? MRECAd {
            return MRECAdView(mrecView: ad.adView)
        }
        return UIView()
    }
    
    override func load(with surroundingIds: [String] = []) {
        guard !isLoading && availableAd == nil else { return }
        isLoading = true
        didDisplay = false

        AdAnalytics.adLoadingStarted.send(params: ["adUnitIdentifier": adUnit])
        loadingView = MAAdView(adUnitIdentifier: AdConfig.mrecAdUnit, adFormat: MAAdFormat.mrec, sdk: AdInitializer.appLoSdk)
        loadingView.delegate = self
        loadingView.revenueDelegate = self
        loadingView.setExtraParameterForKey("allow_pause_auto_refresh_immediately", value: "true")
        loadingView.setLocalExtraParameterForKey("google_max_ad_content_rating", value: "T")
        loadingView.setExtraParameterForKey("allow_pause_auto_refresh_immediately", value: "true")
        loadingView.setLocalExtraParameterForKey("google_neighbouring_content_url_strings", value: surroundingIds)
        
        AH.addBanner(with: .max, adObject: loadingView, delegate: self)

        loadingView.stopAutoRefresh()
        loadingView.loadAd()
        
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
    
    func reset() {
        resetIndexedAd()
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
    
    private func sendAnalytics(_ ad: MAAd, blocked: Bool = false, appHarbrResult: String = "") {
        let adParams = getMAadParameters(ad: ad)
        if didDisplay {
            AdAnalytics.adLoadingFinishedBlocked.send(params: adParams)
        } else {
            AdAnalytics.adLoadingFinished.send(params: adParams)
        }
    }
    
}

// MARK: - MANativeAdDelegate

extension MRECMAadClient: MAAdViewAdDelegate {
    
    func didLoad(_ ad: MAAd) {
        sendAnalytics(ad)
        finishLoading()
        resetAvailableAd()
        
        guard let loadingView = loadingView else { return }
        availableAd = MRECAd(adUnit: adUnit, ad: ad, adView: loadingView)
    }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        adLoadingFailed(for: adUnitIdentifier, with: error)
    }

    func didClick(_ ad: MAAd) {
        AdAnalytics.adClicked.send(params: getMAadParameters(ad: ad))
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {}
    
    func didExpand(_ ad: MAAd) {}
    
    func didCollapse(_ ad: MAAd) {}
    
    func didDisplay(_ ad: MAAd) {
        didDisplay = true
    }
    
    func didHide(_ ad: MAAd) {}
}

//MARK: - AppHarbr
extension MRECMAadClient: AppHarbrDelegate {
    func didAdBlocked(ad: NSObject?, unitId: String?, adForamt: AppHarbrSDK.AdFormat, reasons: [String]) {
        guard let maxAd = ad as? MAAd else { return }
        sendAnalytics(maxAd)
        
        resetIndexedAd()
        resetAvailableAd()
        
        load()
    }
}

extension MRECMAadClient: DTBAdCallback {
    func onSuccess(_ adResponse: DTBAdResponse!) {
        loadingView.setLocalExtraParameterForKey("amazon_ad_response", value: adResponse)
        loadingView.loadAd()
    }
    
    func onFailure(_ error: DTBAdError, dtbAdErrorInfo: DTBAdErrorInfo!) {
        loadingView.setLocalExtraParameterForKey("amazon_ad_error", value:dtbAdErrorInfo)
        loadingView.loadAd()
    }
}
