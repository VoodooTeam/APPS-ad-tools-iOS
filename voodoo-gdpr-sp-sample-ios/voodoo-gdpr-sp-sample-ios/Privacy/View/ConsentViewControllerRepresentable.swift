//
//  ConsentViewControllerRepresentable.swift
//  GDPRConsentPOC
//
//  Created by Sarra Srairi on 29/05/2024.
//

import SwiftUI
import UIKit

struct ConsentViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        DispatchQueue.main.async {
            PrivacyManager.shared.loadAndDisplayConsentUI(from: viewController)
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

