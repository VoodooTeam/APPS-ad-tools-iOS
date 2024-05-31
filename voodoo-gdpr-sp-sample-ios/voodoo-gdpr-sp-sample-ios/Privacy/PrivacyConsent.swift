//
//  PrivacyConsent.swift
//  GDPRConsentPOC
//
//  Created by Sarra Srairi on 29/05/2024.
//

import Foundation

class PrivacyConsent {
    var adsConsent: Bool
    var analyticsConsent: Bool

    init(adsConsent: Bool, analyticsConsent: Bool) {
        self.adsConsent = adsConsent
        self.analyticsConsent = analyticsConsent
    }
}
