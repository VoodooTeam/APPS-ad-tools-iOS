//
//  ATTPrivacyManager.swift
//  GDPRConsentPOC
//
//  Created by Sarra Srairi on 29/05/2024.
//

import AppTrackingTransparency
import AdSupport
import NotificationCenter

final class VoodooATTPrivacyManager {
    static let shared = VoodooATTPrivacyManager()

    private init() {}

    // Method to request ATT authorization using async/await
    @discardableResult
    func requestTrackingAuthorization() async -> ATTrackingManager.AuthorizationStatus {
        var status = await ATTrackingManager.requestTrackingAuthorization()

        // Handle iOS 17.4 bug where status might be incorrectly set
        if status == .denied, ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            let notificationCenter = NotificationCenter.default
            let notifications = await notificationCenter.notifications(named: UIApplication.didBecomeActiveNotification)
            defer {
                notificationCenter.removeObserver(self)
            }

            for await _ in notifications {
                status = await ATTrackingManager.requestTrackingAuthorization()
                if status != .notDetermined {
                    break
                }
            }
        }

        return status
    }

    // Method to fetch the latest IDFA directly from the system
    func fetchIDFA() -> String? {
        if ATTrackingManager.trackingAuthorizationStatus == .authorized {
            return ASIdentifierManager.shared().advertisingIdentifier.uuidString
        } else {
            return nil
        }
    }
}
