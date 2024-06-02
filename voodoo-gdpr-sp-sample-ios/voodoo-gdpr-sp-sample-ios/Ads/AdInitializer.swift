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
                            
    // MARK: - class methods
    
    static func launchAdsSDK() {
        let group = DispatchGroup()
        setupAppHarbr(group)
        setupAppLovin(group)
        group.notify(queue: .main) {
            setupCoordinator()
        }
    }
    
    private static func setupAppHarbr(_ group: DispatchGroup) {
        group.enter()
        let configuration = AppHarbrConfigurationBuilder(apiKey: AdConfig.appHarbrKey).build()
        AH.initializeSdk(configuration: configuration) { error in
            if let error = error {
                print(error)
            } else {
                group.leave()
            }
        }
    }
    
    private static func setupAppLovin(_ group: DispatchGroup) {
        group.enter()

        let initConfig = ALSdkInitializationConfiguration(sdkKey: AdConfig.appLovinKey) { builder in
          builder.mediationProvider = ALMediationProviderMAX
        }
        
        ALPrivacySettings.setHasUserConsent(true)
        ALPrivacySettings.setDoNotSell(false)
        ALPrivacySettings.setIsAgeRestrictedUser(false)

        // Initialize the SDK with the configuration
        ALSdk.shared().initialize(with: initConfig) { sdkConfig in
            FBAdSettings.setDataProcessingOptions([])
            group.leave()
        }
    }
    
    private static func setupCoordinator() {
        AdCoordinator.shared.initWith(
            clients: [
                NativeMAadClient(adUnit: AdConfig.nativeAdUnit, userInfo: .empty),
                MRECMAadClient(adUnit: AdConfig.mrecAdUnit, userInfo: .empty)
            ]
        )
    }
}
