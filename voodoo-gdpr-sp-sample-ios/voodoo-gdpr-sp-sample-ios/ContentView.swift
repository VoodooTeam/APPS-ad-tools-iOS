//
//  ContentView.swift
//  voodoo-gdpr-sp-sample-ios
//
//  Created by Sarra Srairi on 30/05/2024.
//

import SwiftUI

struct ContentView: View {
    @State public var showConsentView = false

    var body: some View {
        VStack {
            Text("Welcome to the App")
                .padding()

            Button(action: {
                showConsentView.toggle()
            }) {
                Text("Show Consent")
            }
        }
        .fullScreenCover(isPresented: $showConsentView) {
            ConsentViewControllerRepresentable()
        }
    }
}
