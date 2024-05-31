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
    static let nativeAdUnit = "252036be5c9ebe29"
    static let mrecAdUnit = "0b317d8985405a5e"
    static let interval = 3
    static let fetchOffset = 2
    static let surroundingUserBaseUrl = "https://crawler.getwizz.io/wizz_profiles.html?uid=%1$@"
    static let amazonSlotID = "b636cd42-59d9-46f6-bec8-017dad7bef1b"
}
