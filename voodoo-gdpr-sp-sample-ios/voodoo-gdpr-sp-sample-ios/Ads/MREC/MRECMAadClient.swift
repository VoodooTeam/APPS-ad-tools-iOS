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
        loadingView = MAAdView(adUnitIdentifier: AdConfig.mrecAdUnit, adFormat: MAAdFormat.mrec, sdk: ALSdk.shared())
        loadingView.delegate = self
        loadingView.revenueDelegate = self
        loadingView.setExtraParameterForKey("allow_pause_auto_refresh_immediately", value: "true")
        loadingView.setLocalExtraParameterForKey("google_max_ad_content_rating", value: "T")
        loadingView.setExtraParameterForKey("allow_pause_auto_refresh_immediately", value: "true")
        loadingView.setLocalExtraParameterForKey("google_neighbouring_content_url_strings", value: getContentMappingUrls(for: surroundingIds))
        
        setBigoParameters()
        
        AH.addBanner(with: .max, adObject: loadingView, delegate: self)

        loadingView.stopAutoRefresh()
        loadingView.loadAd()
        
        let amazonAdLoader = DTBAdLoader()
        let amazonAdSize = DTBAdSize(bannerAdSizeWithWidth: Int(MRECAdView.PublicConstants.adWidth),
                                     height: Int(MRECAdView.PublicConstants.adHeight),
                                     andSlotUUID: AdConfig.amazonSlotID)
        amazonAdLoader.setAdSizes([amazonAdSize!])
        loadBackgroundQueue.async { amazonAdLoader.loadAd(self) }
    }


    // MARK: - Private
    
    private func setBigoParameters() {
        if let age = userInfo?.age {
            loadingView.setLocalExtraParameterForKey("bigoads_age", value: "\(age)")
        }
        if let gender = userInfo?.gender {
            loadingView.setLocalExtraParameterForKey("bigoads_gender", value: "\(gender)")
        }
        if let activatedTime = userInfo?.activatedTime {
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
        availableAd = MRECAd(adUnit: adUnit, ad: ad, adView: loadingView)
    }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        adLoadingFailed(for: adUnitIdentifier, with: error)
    }

    func didClick(_ ad: MAAd) {
        AdAnalytics.adClicked.send(params: getMAadParameters(ad: ad))
    }
    
    func didDisplay(_ ad: MAAd) {
        didDisplay = true
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {}
    
    func didExpand(_ ad: MAAd) {}
    
    func didCollapse(_ ad: MAAd) {}
    
    func didHide(_ ad: MAAd) {}
}

//MARK: - AppHarbrDelegate

extension MRECMAadClient: AppHarbrDelegate {
    func didAdBlocked(ad: NSObject?, unitId: String?, adForamt: AppHarbrSDK.AdFormat, reasons: [String]) {
        guard let maxAd = ad as? MAAd else { return }
        sendAnalytics(maxAd)
        availableAd = nil
        load()
    }
}

// MARK: - DTBAdCallback

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
