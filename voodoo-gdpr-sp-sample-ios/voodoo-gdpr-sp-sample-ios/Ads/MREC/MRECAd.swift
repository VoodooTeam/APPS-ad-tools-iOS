//
//  MRECAd.swift
//  Drop
//
//  Created by Loïc Saillant on 29/05/2024.
//

import Foundation
import AppLovinSDK

final class MRECAd: MAXAd {
    let adView: MAAdView

    init(adUnit: String, ad: MAAd, adView: MAAdView) {
        self.adView = adView
        super.init(adUnit: adUnit, ad: ad, type: .mrec)
    }
}
