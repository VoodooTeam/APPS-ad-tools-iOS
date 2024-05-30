//
//  VoodooPrivacyConsent.swift
//  GDPRConsentPOC
//
//  Created by Sarra Srairi on 29/05/2024.
//

import Foundation

class VoodooPrivacyConsent {
    var adsConsent: Bool
    var analyticsConsent: Bool

    init(adsConsent: Bool, analyticsConsent: Bool) {
        self.adsConsent = adsConsent
        self.analyticsConsent = analyticsConsent
    }
}
