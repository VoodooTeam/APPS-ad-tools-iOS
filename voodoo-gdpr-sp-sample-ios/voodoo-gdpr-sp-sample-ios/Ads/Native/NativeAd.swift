//
//  NativeAd.swift
//  Drop
//
//  Created by Loïc Saillant on 28/05/2024.
//

import Foundation
import AppLovinSDK

final class NativeAd: Ad {
    let adUnit: String
    let ad: MAAd
    var index: Int?
    var type: AdType = .native
    
    var price: Double {
        return ad.revenue
    }
    
    init(adUnit: String, ad: MAAd) {
        self.adUnit = adUnit
        self.ad = ad
    }
}
