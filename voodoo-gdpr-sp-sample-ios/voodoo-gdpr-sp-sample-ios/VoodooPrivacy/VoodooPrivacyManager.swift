//
//  VoodooPrivacyManager.swift
//  GDPRConsentPOC
//
//  Created by Sarra Srairi on 29/05/2024.
//

import Foundation
import ConsentViewController
import UIKit
import SwiftUI

final class VoodooPrivacyManager {

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

        static func == (lhs: VoodooPrivacyManager.Status, rhs: VoodooPrivacyManager.Status) -> Bool {
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

    static let shared = VoodooPrivacyManager()

    // MARK: - Properties

    private var consentManager: SPSDK?
    private var consentViewController: UIViewController?
    private var onCompletion: ((Status) -> Void)?
    private(set) var fromViewController: UIViewController?
    private(set) var status: Status = .notRequested

    private var purposeConsentDictionary: [Purpose: Bool] = [:]
    private var keyPurposeDictionary: [String: Purpose] = [:]

    // MARK: - Initializer

    private init() {}

    // MARK: - Public Methods

    func configure() {
        GDPRService.shared.fetchConfig { [weak self] gdprEnabled in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if gdprEnabled {
                    self.setupConsentManager()
                    self.initializeKeyPurposeDictionary()
                    self.loadConsentUI()
                } else {
                    self.status = .notAvailable
                }
            }
        }
    }
    
    private func launchSDKs() {
        let consent = getPrivacyConsent()
        print("Consent privacy ads: \(consent.adsConsent)")
        print("Consent privacy analytics: \(consent.analyticsConsent)")

        if consent.adsConsent {
            // Initialize Ads SDK
        }

        if consent.analyticsConsent {
            // Initialize Analytics SDK
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


    func loadAndDisplayConsentUI(from: UIViewController) {
        guard let consentManager else {
            if status != .notAvailable {
                status = .error(PrivacyError.consentManagerUnavailable)
            }
            return
        }

        fromViewController = from
        consentManager.loadGDPRPrivacyManager(withId: SourcepointConfiguration.privacyManagerId)
    }

    func isPurposeAuthorized(_ purpose: Purpose) -> Bool {
        return purposeConsentDictionary[purpose] ?? false
    }

    func deleteConsents() {
        SPConsentManager.clearAllData()
        status = .running
        loadConsentUI()
    }

    // MARK: - Private Methods

    private func setupConsentManager() {
        consentManager = SPConsentManager(
            accountId: SourcepointConfiguration.accountId,
            propertyId: SourcepointConfiguration.propertyId,
            propertyName: try! SPPropertyName(SourcepointConfiguration.propertyName),
            campaigns: SPCampaigns(
                gdpr: SPCampaign(),
                ccpa: SPCampaign(),
                ios14: SPCampaign()
            ),
            language: .BrowserDefault,
            delegate: self
        )
        status = .running
    }

    private func initializeKeyPurposeDictionary() {
        keyPurposeDictionary = [
            SourcepointConfiguration.storeAndAccessInformationOnDeviceKey: .StoreAndAccessInformationOnDevice,
            SourcepointConfiguration.selectBasicAdsKey: .SelectBasicAds,
            SourcepointConfiguration.createPersonalisedAdsProfileKey: .CreatePersonalisedAdsProfile,
            SourcepointConfiguration.selectPersonalisedAdsKey: .SelectPersonalisedAds,
            SourcepointConfiguration.createPersonalisedContentProfileKey: .CreatePersonalisedContentProfile,
            SourcepointConfiguration.selectPersonalisedContentKey: .SelectPersonalisedContent,
            SourcepointConfiguration.measureAdsPerformanceKey: .MeasureAdsPerformance,
            SourcepointConfiguration.measureContentPerformanceKey: .MeasureContentPerformance,
            SourcepointConfiguration.applyMarketResearchToGenerateAudienceInsightsKey: .ApplyMarketResearchToGenerateAudienceInsights,
            SourcepointConfiguration.developAndImproveProductsKey: .DevelopAndImproveProducts
        ]
    }

    private func loadConsentUI() {
        consentManager?.loadMessage()
    }

    private func updatePurposeConsentDictionary(_ gdprConsent: SPGDPRConsent) {
        purposeConsentDictionary = keyPurposeDictionary.reduce(into: [Purpose: Bool]()) { dict, keyPurpose in
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

    private func getPrivacyConsent() -> VoodooPrivacyConsent {
        return VoodooPrivacyConsent(
            adsConsent: purposeConsentDictionary[.StoreAndAccessInformationOnDevice] ?? false &&
                        purposeConsentDictionary[.SelectBasicAds] ?? false &&
                        purposeConsentDictionary[.CreatePersonalisedAdsProfile] ?? false &&
                        purposeConsentDictionary[.SelectPersonalisedAds] ?? false &&
                        purposeConsentDictionary[.CreatePersonalisedContentProfile] ?? false &&
                        purposeConsentDictionary[.SelectPersonalisedContent] ?? false,

            analyticsConsent: purposeConsentDictionary[.StoreAndAccessInformationOnDevice] ?? false &&
                              purposeConsentDictionary[.MeasureAdsPerformance] ?? false &&
                              purposeConsentDictionary[.MeasureContentPerformance] ?? false &&
                              purposeConsentDictionary[.ApplyMarketResearchToGenerateAudienceInsights] ?? false &&
                              purposeConsentDictionary[.DevelopAndImproveProducts] ?? false
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

extension VoodooPrivacyManager: SPDelegate {
    func onSPUIReady(_ controller: UIViewController) {
        controller.modalPresentationStyle = .overFullScreen

        consentViewController = controller
        status = .available

        if let fromViewController {
            displayContentUI(from: fromViewController)
        } else if let topController = topMostViewController() {
            displayContentUI(from: topController)
        }
    }

    func onSPUIFinished(_ controller: UIViewController) {
        /* La joie du swiftUI + UIKIT :) please adpot it to your code <3 */
        controller.dismiss(animated: true) {
            if let topController = self.topMostViewController() {
                topController.dismiss(animated: true) {
                    self.onCompletion?(self.status)
                    self.onCompletion = nil
                }
            } else {
                self.onCompletion?(self.status)
                self.onCompletion = nil
            }
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

        if let gdprConsent = userData.gdpr?.consents {
            updatePurposeConsentDictionary(gdprConsent)
        }

        launchSDKs()
    }
} 
