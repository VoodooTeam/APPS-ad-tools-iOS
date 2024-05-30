//
//  SourcePointConfig.swift
//  GDPRConsentPOC
//
//  Created by Sarra Srairi on 29/05/2024.
//

import Foundation

struct SourcepointConfiguration {
    static let accountId = 1909
    static let propertyId = 33918
    static let privacyManagerId = "900785"
    static let propertyName = "wemoms"

    static let storeAndAccessInformationOnDeviceKey = "6548eb4444030704e1e66fbd"
    static let selectBasicAdsKey = "6548eb4444030704e1e66fef"
    static let createPersonalisedAdsProfileKey = "6548eb4444030704e1e66fc7"
    static let selectPersonalisedAdsKey = "6548eb4444030704e1e66fcc"
    static let createPersonalisedContentProfileKey = "6548eb4444030704e1e66fd6"
    static let selectPersonalisedContentKey = "6548eb4444030704e1e66fd1"
    static let measureAdsPerformanceKey = "6548eb4444030704e1e66fdb"
    static let measureContentPerformanceKey = "6548eb4444030704e1e66fe0"
    static let applyMarketResearchToGenerateAudienceInsightsKey = "6548eb4444030704e1e66fe5"
    static let developAndImproveProductsKey = "6548eb4444030704e1e66fea"

}

enum Purpose: String {
    case Age
    case StoreAndAccessInformationOnDevice
    case SelectBasicAds
    case CreatePersonalisedAdsProfile
    case SelectPersonalisedAds
    case CreatePersonalisedContentProfile
    case SelectPersonalisedContent
    case MeasureAdsPerformance
    case MeasureContentPerformance
    case ApplyMarketResearchToGenerateAudienceInsights
    case DevelopAndImproveProducts
}

