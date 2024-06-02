//
//  MAad.swift
//  voodoo-gdpr-sp-sample-ios
//
//  Created by Gautier Gedoux on 31/05/2024.
//

import Foundation
import AppLovinSDK

class MAXAd: Ad {
    let adUnit: String
    let ad: MAAd
    let type: AdType
    var index: Int?
    
    var price: Double {
        return ad.revenue
    }
    
    init(adUnit: String, ad: MAAd, type: AdType) {
        self.adUnit = adUnit
        self.ad = ad
        self.type = type
    }
}
