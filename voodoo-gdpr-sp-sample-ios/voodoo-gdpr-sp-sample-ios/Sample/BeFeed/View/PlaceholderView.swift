//
//  PlaceholderView.swift
//  voodoo-gdpr-sp-sample-ios
//
//  Created by Loïc Saillant on 30/05/2024.
//

import SwiftUI

struct PlaceholderView: View {

    @State private var didAppear = false
    
    var body: some View {
        Rectangle()
            .foregroundStyle(LinearGradient(colors: [.gray.opacity(didAppear ? 1 : 0.5), .gray.opacity(didAppear ? 0.5 : 1)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing))
            .onAppear {
                withAnimation(.linear(duration: 1.0).repeatForever()) {
                    didAppear = true
                }
            }
    }
    
}

#Preview {
    PlaceholderView()
}
