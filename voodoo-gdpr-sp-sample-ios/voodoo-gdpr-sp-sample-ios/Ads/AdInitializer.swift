//
//  AdManager.swift
//  BeFake
//
//  Created by Gautier Gedoux on 22/05/2024.
//

import Foundation
import AppLovinSDK
import FBAudienceNetwork
import UIKit
import AppHarbrSDK

class AdInitializer: NSObject {
        
    // MARK: - Static properties
            
    private static var isStarted = false
    
    static var appLoSdk: ALSdk {
        let alSdk = ALSdk.shared(withKey: AdConfig.appLovinKey)!
        alSdk.mediationProvider = "max"
        return alSdk
    }
    
    // MARK: - class methods
    
    static func launchAdsSDK() {
        guard !isStarted else { return }
        ALPrivacySettings.setHasUserConsent(true)
        ALPrivacySettings.setDoNotSell(false)
        ALPrivacySettings.setIsAgeRestrictedUser(false)
        
        setupAppHarbr()
        appLoSdk.initializeSdk { (configuration: ALSdkConfiguration) in
            FBAdSettings.setDataProcessingOptions([])
            isStarted = true
            AdCoordinator.shared.initWith(
                clients: [
                    NativeMAadClient(adUnit: AdConfig.nativeAdUnit, userInfo: .empty),
                    MRECMAadClient(adUnit: AdConfig.mrecAdUnit, userInfo: .empty)
                ]
            )
        }
    }
    
    static func setupAppHarbr() {
        let configuration = AppHarbrConfigurationBuilder(apiKey: AdConfig.appHarbrKey).build()
        AH.initializeSdk(configuration: configuration) { error in
            if let error = error {
                print(error)
                return
            }
        }
    }
}
