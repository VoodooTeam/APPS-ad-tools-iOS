//
//  AdView.swift
//  Drop
//
//  Created by Michel-André Chirita on 26/05/2024.
//

import SwiftUI

struct AdView: UIViewRepresentable {
    
    let adIndex: Int
    
    func makeUIView(context: Context) -> UIView {
        return AdCoordinator.shared.getAdView(for: adIndex)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}
