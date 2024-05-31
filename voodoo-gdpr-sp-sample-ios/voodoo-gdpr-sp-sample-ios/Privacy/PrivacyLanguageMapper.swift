//
//  PrivacyLanguageMapper.swift
//  voodoo-gdpr-sp-sample-ios
//
//  Created by Sarra Srairi on 30/05/2024.
//

import Foundation
import ConsentViewController

class PrivacyLanguageMapper {
    static func mapLanguageCodeToSPMessageLanguage() -> SPMessageLanguage {
        let languageCode = Locale.current.language.languageCode?.identifier ?? "en"

        switch languageCode.lowercased() {
        case "en": return .English
        case "fr": return .French
        case "de": return .German
        case "it": return .Italian
        case "nl": return .Dutch
        case "pt": return .Portuguese
        case "sv": return .Swedish
        default: return .BrowserDefault
        }
    }
}
