//
//  AdAnalytics.swift
//  voodoo-gdpr-sp-sample-ios
//
//  Created by Gautier Gedoux on 02/06/2024.
//

import Foundation

enum AdAnalytics: String {
    //ad
    case adWatched = "Ad Watched"
    case adClicked = "Ad Clicked"
    case adLoadingStarted = "Ad Loading Started"
    case adLoadingFinished = "Ad Loading Finished"
    case adLoadingFailed = "Ad Loading Failed"
    case adLoadingFinishedBlocked = "Ad Loading Finished Blocked"
    case adDisplayBlocked = "Ad Display Blocked"
    
    func send(params: [String: Any]) {
        //TODO: to be completed by Limitless team
        print("📊 \(rawValue), adUnit \(params["adUnitIdentifier"] ?? "unknown")")
    }
}
