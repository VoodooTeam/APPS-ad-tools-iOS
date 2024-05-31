//
//  SourcePointConfig.swift
//  GDPRConsentPOC
//
//  Created by Sarra Srairi on 29/05/2024.
//

import Foundation

struct SourcepointConfiguration {
    static let accountId = 1909
    static let propertyId = 36309
    static let privacyManagerId = "1142456"
    static let propertyName = "voodoo.native.app"

    static let storeAndAccessInformationOnDeviceKey = "6656fcd5a0fa9305065e56a3"
    static let selectBasicAdsKey = "6656fcd5a0fa9305065e562c"
    static let createPersonalisedAdsProfileKey = "6656fcd5a0fa9305065e55e7"
    static let selectPersonalisedAdsKey = "6656fcd5a0fa9305065e557e"
    static let createPersonalisedContentProfileKey = "6656fcd5a0fa9305065e5574"
    static let selectPersonalisedContentKey = "6656fcd5a0fa9305065e556a"
    static let measureAdsPerformanceKey = "6656fcd5a0fa9305065e5415"
    static let measureContentPerformanceKey = "6656fcd5a0fa9305065e5490"
    static let applyMarketResearchToGenerateAudienceInsightsKey = "6656fcd5a0fa9305065e54a9"
    static let developAndImproveProductsKey = "6656fcd5a0fa9305065e54f3"
    static let useLimitedDataContent = "6656fcd5a0fa9305065e5561"

}

enum Purpose: String {
    case StoreAndAccessInformationOnDevice
    case SelectBasicAds
    case CreatePersonalisedAdsProfile
    case SelectPersonalisedAds
    case MeasureAdsPerformance
    case MeasureContentPerformance
    case ApplyMarketResearchToGenerateAudienceInsights
    case DevelopAndImproveProducts
    case UseLimitedDataContent
}

