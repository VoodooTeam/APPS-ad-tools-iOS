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

enum MediationProvider: String {
    case max
}

final class AdInitializer: NSObject {
        
    // MARK: - Static properties
    
    static var nativeAdLoader = MANativeAdLoader(adUnitIdentifier: AdConfig.nativeAdUnit, sdk: ALSdk.shared())
            
    private static var isStarted = false
    
    // MARK: - class methods
    
    static func launchAdsSDK(hasUserConsent: Bool, doNotSell: Bool, isAgeRestrictedUser: Bool) {
        guard !isStarted else { return }
        ALPrivacySettings.setHasUserConsent(hasUserConsent)
        ALPrivacySettings.setDoNotSell(doNotSell)
        ALPrivacySettings.setIsAgeRestrictedUser(isAgeRestrictedUser)
        
        setupAppHarbr()
        let configuration = ALSdkInitializationConfiguration(sdkKey: AdConfig.appLovinKey) { configuration in
            configuration.mediationProvider = MediationProvider.max.rawValue
        }
        ALSdk.shared().initialize(with: configuration) { configuration in
            FBAdSettings.setDataProcessingOptions([])
            isStarted = true
            AdCoordinator.shared.initWith(
                clients: [
                    NativeMAadClient(userInfo: .empty),
                    MRECMAadClient(userInfo: .empty)
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
