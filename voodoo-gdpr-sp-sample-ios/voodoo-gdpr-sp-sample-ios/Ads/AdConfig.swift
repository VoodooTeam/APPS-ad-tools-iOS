//
//  AdConfig.swift
//  Drop
//
//  Created by Loïc Saillant on 28/05/2024.
//

import Foundation

// TODO: (Loic Saillant) 2024/05/28 Should not be hardcoded but encrypted somewhere

struct AdConfig {
    static let gadNativeAdViewTag = 1008
    static let appLovinKey = "E1M7r57HoT7PoxvgxbXnJLA55TKI1GOGHmO6rVNdzV1mQwQMWz7rJIxOrGgtW48prWwf1II-oKkDF9Zn7gbQzX"
    static let appHarbrKey = "6d693b09-dde8-45a2-86d4-f0ad12ad655e"
    static let nativeAdUnit = "0dc625952c9f618f"
    static let mrecAdUnit = "c570096f8b9c6c91"
    static let interval = 3
    static let fetchOffset = 2
    static let surroundingUserBaseUrl = "https://crawler.getwizz.io/wizz_profiles.html?uid=%1$@"
    static let amazonSlotID = "c68543e9-660a-48d0-97b6-d2d608649364"
}
