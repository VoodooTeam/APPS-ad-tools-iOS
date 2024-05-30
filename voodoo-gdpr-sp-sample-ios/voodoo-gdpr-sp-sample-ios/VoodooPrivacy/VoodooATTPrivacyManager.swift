//
//  ATTPrivacyManager.swift
//  GDPRConsentPOC
//
//  Created by Sarra Srairi on 29/05/2024.
//

import AppTrackingTransparency
import AdSupport

final class VoodooATTPrivacyManager {
    static let shared = VoodooATTPrivacyManager()

    private init() {}

    private let userDefaultsKey = "voodoo-identifier-sp"

    // Method to check ATT status and retrieve the IDFA
    func checkATTStatus(completion: @escaping (String?) -> Void) {

        // Check if IDFA is already stored in UserDefaults
        if let storedIDFA = UserDefaults.standard.string(forKey: userDefaultsKey) {
            completion(storedIDFA)
            return
        }

        // Request ATT authorization
        ATTrackingManager.requestTrackingAuthorization { status in
            switch status {
            case .authorized:
                let advertisingId = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                // Store the IDFA in UserDefaults
                UserDefaults.standard.set(advertisingId, forKey: self.userDefaultsKey)
                completion(advertisingId)
            case .denied, .restricted, .notDetermined:
                completion(nil)
            @unknown default:
                completion(nil)
            }
        }
    }
}
