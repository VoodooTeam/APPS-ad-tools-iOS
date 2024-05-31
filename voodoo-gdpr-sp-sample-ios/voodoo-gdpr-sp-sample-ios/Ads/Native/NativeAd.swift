//
//  NativeAd.swift
//  Drop
//
//  Created by Loïc Saillant on 28/05/2024.
//

import Foundation
import AppLovinSDK

final class NativeAd: MAXAd {
    
    init(adUnit: String, ad: MAAd) {
        super.init(adUnit: adUnit, ad: ad, type: .native)
    }
}
