//
//  PrivacyManager.swift
//  GDPRConsentPOC
//
//  Created by Sarra Srairi on 29/05/2024.
//

import Foundation
import ConsentViewController
import UIKit
import SwiftUI

final class PrivacyManager {

    // MARK: - Enums
    
    enum PrivacyError: Error {
        case unknown
        case consentManagerUnavailable
    }
    
    enum Status: Equatable {
        case notAvailable
        case notRequested
        case running
        case available
        case finished
        case error(Error)

        static func == (lhs: PrivacyManager.Status, rhs: PrivacyManager.Status) -> Bool {
            switch (lhs, rhs) {
            case (.notAvailable, .notAvailable),
                (.notRequested, .notRequested),
                (.running, .running),
                (.available, .available),
                (.finished, .finished):
                return true
            default:
                return false
            }
        }
    }
    
    // MARK: - Singleton

    static let shared = PrivacyManager()

    // MARK: - Properties

    private var consentManager: SPSDK?
    private var consentViewController: UIViewController?
    private var onCompletion: ((Status) -> Void)?
    private(set) var status: Status = .notRequested
    private var purposeConsentDictionary: [PrivacyPurpose: Bool] = [:]
    private var keyPurposeDictionary: [String: PrivacyPurpose] = [:]
    var language: SPMessageLanguage?
    
    private var hasUserConsent: Bool {
        getGdprPrivacyConsent().adsConsent
    }
    private var doNotSellEnabled: Bool = false
    private var isAgeRestrictedUser: Bool {
        false
    }


    // MARK: - Initializer

    private init() {}

    // MARK: - Public Methods

    func configure() {
        self.setupConsentManager()
        self.initializeKeyPurposeDictionary()
        self.loadConsentUI()
    }
    
    private func launchSDKs() {

        print("🧙🏻‍♂️ launchSDKs")
        
        let consent = getGdprPrivacyConsent()
        print("Consent privacy ads: \(consent.adsConsent)")
        print("Consent privacy analytics: \(consent.analyticsConsent)")
        print("Do Not Sell Data enabled: \(doNotSellEnabled)")
        
        Task {
            await PrivacyATTManager.shared.requestTrackingAuthorization()
        }
        
        if shouldPrivacyApplicable() {
            if consent.adsConsent {
                AdInitializer.launchAdsSDK(
                    hasUserConsent: hasUserConsent,
                    doNotSell: doNotSellEnabled,
                    isAgeRestrictedUser: isAgeRestrictedUser
                )
            }

            if consent.analyticsConsent {
                // Initialize Analytics SDK
            }
            
        } else {
            AdInitializer.launchAdsSDK(
                hasUserConsent: hasUserConsent,
                doNotSell: doNotSellEnabled,
                isAgeRestrictedUser: isAgeRestrictedUser
            )
        }

        
    }

    func displayContentUI(from: UIViewController, completion: ((Status) -> Void)? = nil) {
        guard let consentViewController, status == .available else {
            completion?(.error(PrivacyError.consentManagerUnavailable))
            return
        }
        onCompletion = completion
        from.present(consentViewController, animated: true)
    }

    func loadAndDisplayConsentUI() {
        guard let consentManager else {
            if status != .notAvailable {
                status = .error(PrivacyError.consentManagerUnavailable)
            }
            return
        }

        if shouldPrivacyApplicable() {
            if(consentManager.usnatApplies) {
                consentManager.loadGDPRPrivacyManager(withId: PrivacyConfig.usMspsPrivacyManagerId)
            } else {
                consentManager.loadGDPRPrivacyManager(withId:PrivacyConfig.gdprPrivacyManagerId)
            }
        } else {
            status = .notAvailable
            print("Privacy -- not available in your country")
        }
    }

    func shouldPrivacyApplicable() -> Bool {
        guard let consentManager else {
            return false
        }
        return consentManager.gdprApplies || consentManager.usnatApplies || consentManager.ccpaApplies
    }

    func isPurposeAuthorized(_ purpose: PrivacyPurpose) -> Bool {
        return purposeConsentDictionary[purpose] ?? false
    }

    func deleteConsents() {
        SPConsentManager.clearAllData()
        status = .running
        loadConsentUI()
    }

    // MARK: - Private Methods

    private func setupConsentManager() {
        let language = PrivacyLanguageMapper.mapLanguageCodeToSPMessageLanguage()
        consentManager = SPConsentManager(
            accountId: PrivacyConfig.accountId,
            propertyId: PrivacyConfig.propertyId,
            propertyName: try! SPPropertyName(PrivacyConfig.propertyName),
            campaigns: SPCampaigns(
                gdpr: SPCampaign(),
                usnat: SPCampaign(transitionCCPAAuth: true),
                ios14: SPCampaign()
            ),
            language: language,
            delegate: self
        )
        status = .running
    }

    private func initializeKeyPurposeDictionary() {
        keyPurposeDictionary = [
            PrivacyConfig.storeAndAccessInformationOnDeviceKey: .StoreAndAccessInformationOnDevice,
            PrivacyConfig.selectBasicAdsKey: .SelectBasicAds,
            PrivacyConfig.createPersonalisedAdsProfileKey: .CreatePersonalisedAdsProfile,
            PrivacyConfig.selectPersonalisedAdsKey: .SelectPersonalisedAds,
            PrivacyConfig.measureAdsPerformanceKey: .MeasureAdsPerformance,
            PrivacyConfig.measureContentPerformanceKey: .MeasureContentPerformance,
            PrivacyConfig.applyMarketResearchToGenerateAudienceInsightsKey: .ApplyMarketResearchToGenerateAudienceInsights,
            PrivacyConfig.developAndImproveProductsKey: .DevelopAndImproveProducts,
            PrivacyConfig.useLimitedDataContent: .UseLimitedDataContent
        ]
    }

    private func loadConsentUI() {
        consentManager?.loadMessage()
    }

    private func updatePurposeConsentDictionary(_ gdprConsent: SPGDPRConsent) {
        purposeConsentDictionary = keyPurposeDictionary.reduce(into: [PrivacyPurpose: Bool]()) { dict, keyPurpose in
            dict[keyPurpose.value] = true
        }

        for grant in gdprConsent.vendorGrants {
            for purposeGrant in grant.value.purposeGrants where !purposeGrant.value {
                if let purpose = keyPurposeDictionary[purposeGrant.key] {
                    purposeConsentDictionary[purpose] = false
                }
            }
        }
    }

    private func getGdprPrivacyConsent() -> GdprPrivacyConsent {
        return GdprPrivacyConsent(
            adsConsent: purposeConsentDictionary[.StoreAndAccessInformationOnDevice] ?? false &&
                        purposeConsentDictionary[.SelectBasicAds] ?? false &&
                        purposeConsentDictionary[.CreatePersonalisedAdsProfile] ?? false &&
                        purposeConsentDictionary[.SelectPersonalisedAds] ?? false,

            analyticsConsent: purposeConsentDictionary[.StoreAndAccessInformationOnDevice] ?? false &&
                              purposeConsentDictionary[.MeasureAdsPerformance] ?? false &&
                              purposeConsentDictionary[.MeasureContentPerformance] ?? false &&
                              purposeConsentDictionary[.ApplyMarketResearchToGenerateAudienceInsights] ?? false &&
                              purposeConsentDictionary[.DevelopAndImproveProducts] ?? false &&
                              purposeConsentDictionary[.UseLimitedDataContent] ?? false
        )
    }

    private func topMostViewController() -> UIViewController? {
        if let rootViewController = UIApplication.shared.connectedScenes
            .compactMap({ ($0 as? UIWindowScene)?.windows.first?.rootViewController })
            .first {

            var topController = rootViewController

            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            return topController
        }
        return nil
    }
}

// MARK: - SPDelegate

extension PrivacyManager: SPDelegate {
    func onSPUIReady(_ controller: UIViewController) {
        controller.modalPresentationStyle = .overFullScreen

        consentViewController = controller
        status = .available

        guard let topController = topMostViewController() else { return }
        displayContentUI(from: topController)
    }

    func onSPUIFinished(_ controller: UIViewController) {
        controller.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.onCompletion?(self.status)
            self.onCompletion = nil
        }
    }


    func onAction(_ action: ConsentViewController.SPAction, from controller: UIViewController) {}

    func onError(error: SPError) {
        status = .error(error)
    }

    func onConsentReady(userData: SPUserData) {
        status = .available

        if let gdprConsent = userData.gdpr?.consents {
            updatePurposeConsentDictionary(gdprConsent)
        }
        launchSDKs()
    }

    func onSPNativeMessageReady(_ message: SPNativeMessage) {}

    func onSPFinished(userData: SPUserData) {
        status = .finished
        if (userData.usnat?.applies == true) {
            doNotSellEnabled = userData.usnat?.consents?.statuses.sellStatus ?? false
        }
        
        if let gdprConsent = userData.gdpr?.consents {
            updatePurposeConsentDictionary(gdprConsent)
        }
    }
} 
