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
import DTBiOSSDK

class AdInitializer: NSObject {
                            
    // MARK: - class methods
    
    static func launchAdsSDK(hasUserConsent: Bool, doNotSell: Bool, isAgeRestrictedUser: Bool) {
        Task {
            async let appHarbrResult = setupAppHarbr()
            async let appLovinResult = setupAppLovin(
                hasUserConsent: hasUserConsent,
                doNotSell: doNotSell,
                isAgeRestrictedUser: isAgeRestrictedUser
            )
            let results = await [appHarbrResult, appLovinResult]
            if case .failure(let error) = results.first {
                print("[AppHarbr init error] \(error)")
            }
            await MainActor.run {
                AdCoordinator.shared.launch(with: [
                    NativeMAadClient(adUnit: AdConfig.nativeAdUnit, userInfo: .empty),
                    MRECMAadClient(adUnit: AdConfig.mrecAdUnit, userInfo: .empty)
                ])
            }
        }
    }
    
    private static func setupAppHarbr() async -> Result<Void, Error> {
        let configuration = AppHarbrConfigurationBuilder(apiKey: AdConfig.appHarbrKey).build()
        
        return await withCheckedContinuation { continuation in
            AH.initializeSdk(configuration: configuration) { error in
                if let error = error {
                    continuation.resume(returning: .failure(error))
                }
                else {
                    continuation.resume(returning: .success(()))
                }
            }
        }
    }
    
    private static func setupAppLovin(hasUserConsent: Bool,
                                      doNotSell: Bool,
                                      isAgeRestrictedUser: Bool) async -> Result<Void, Error> {
        
        let initConfig = ALSdkInitializationConfiguration(sdkKey: AdConfig.appLovinKey) { builder in
            builder.mediationProvider = ALMediationProviderMAX
        }
        
        ALPrivacySettings.setHasUserConsent(hasUserConsent)
        ALPrivacySettings.setDoNotSell(doNotSell)
        ALPrivacySettings.setIsAgeRestrictedUser(isAgeRestrictedUser)

        // Initialize the SDK with the configuration
        return await withCheckedContinuation { continuation in
            ALSdk.shared().initialize(with: initConfig) { sdkConfig in
                FBAdSettings.setDataProcessingOptions([])
                setupAmazonAdsIfNeeded()
                continuation.resume(returning: .success(()))
            }
        }
    }
    
    private static func setupAmazonAdsIfNeeded() {
        DTBAds.sharedInstance().setAppKey(AdConfig.amazonAppID)
        let adNetworkInfo = DTBAdNetworkInfo(networkName: DTBADNETWORK_MAX)
        DTBAds.sharedInstance().mraidCustomVersions = ["1.0", "2.0", "3.0"]
        DTBAds.sharedInstance().setAdNetworkInfo(adNetworkInfo)
        DTBAds.sharedInstance().mraidPolicy = CUSTOM_MRAID
    }
    
    static func resetAdsSDK() {
        AdCoordinator.shared.restart()
    }
}
