//
//  AppDelegate.swift
//  GDPRConsentPOC
//
//  Created by Sarra Srairi on 29/05/2024.
//

import Foundation
import UIKit
import SwiftUI

@main
final class AppDelegate: NSObject, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        PrivacyManager.shared.configure()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewModel = BeFeedViewModel()
        window?.rootViewController = UIHostingController(
            rootView: BeFeedView(viewModel: .init())
        )
        window?.makeKeyAndVisible()
        
        return true
    }
}
