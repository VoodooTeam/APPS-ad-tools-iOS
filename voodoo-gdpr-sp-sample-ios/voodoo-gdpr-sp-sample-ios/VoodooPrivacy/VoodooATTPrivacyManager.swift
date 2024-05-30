//
//  ATTPrivacyManager.swift
//  GDPRConsentPOC
//
//  Created by Sarra Srairi on 29/05/2024.
//

import Foundation
import UserNotifications
import AppTrackingTransparency
import AdSupport

final class VoodooATTPrivacyManager {
    
    // Method to check ATT status
    private func checkATTStatus(completion: @escaping (String?) -> Void) {
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                let advertisingId = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                completion(advertisingId)
            default:
                completion(nil)
            }
        }
    }
}
