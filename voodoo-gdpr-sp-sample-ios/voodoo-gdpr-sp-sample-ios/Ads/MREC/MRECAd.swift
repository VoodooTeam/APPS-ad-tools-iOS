//
//  MRECAd.swift
//  Drop
//
//  Created by Loïc Saillant on 29/05/2024.
//

import Foundation
import AppLovinSDK

final class MRECAd: Ad {
    let adUnit: String
    let ad: MAAd
    let adView: MAAdView
    var index: Int?
    var type: AdType = .mrec
    
    var price: Double {
        return ad.revenue
    }
    
    init(adUnit: String, ad: MAAd, adView: MAAdView) {
        self.adUnit = adUnit
        self.ad = ad
        self.adView = adView
    }
}
