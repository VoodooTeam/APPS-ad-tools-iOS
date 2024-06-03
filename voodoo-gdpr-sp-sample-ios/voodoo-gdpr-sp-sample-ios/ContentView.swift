//
//  ContentView.swift
//  voodoo-gdpr-sp-sample-ios
//
//  Created by Sarra Srairi on 30/05/2024.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        VStack {
            Text("Welcome to the App")
                .padding()

            Button(action: {
                PrivacyManager.shared.loadAndDisplayConsentUI()
            }) {
                Text("Show Consent")
            }
        }
    }
}
