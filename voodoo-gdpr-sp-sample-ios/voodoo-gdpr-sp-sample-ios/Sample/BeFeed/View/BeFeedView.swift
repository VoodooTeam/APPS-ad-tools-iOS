//
//  BeFeedView.swift
//  Drop
//
//  Created by Michel-André Chirita on 22/05/2024.
//

import SwiftUI
import AppLovinSDK

struct BeFeedView: View {
    
    @StateObject var viewModel: BeFeedViewModel
    @State var showConsentView: Bool = false
    

    var body: some View {
        VStack {
            horizontalFeedView
        }
        .ignoresSafeArea(.container)
        .background(.black)
    }

    @ViewBuilder private var horizontalFeedView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 30) {
                HStack {
                    Button("AppLo Debug") {
                        ALSdk.shared().showMediationDebugger()
                    }
                    Spacer()
                    Button("Privacy Settings") {
                        showConsentView = true
                    }
                }.padding(.horizontal, 8)
                ForEach(viewModel.feedItems) { item in
                    switch item.content {
                    case .media(let media):
                        BeMediaView(viewModel: viewModel.cellViewModel(for: media))
                            .containerRelativeFrame(.horizontal)
                            .onAppear {
                                viewModel.didDisplay(item: item)
                            }
                    case .adIndex(let adIndex):
                        AdView(adIndex: adIndex)
                            .containerRelativeFrame(.horizontal)
                            .frame(height: 650)
                            .onAppear {
                                viewModel.didDisplay(item: item)
                            }
                    }
                }
                .fullScreenCover(isPresented: $showConsentView) {
                    ConsentViewControllerRepresentable()
                }
            }
            .padding(.top, 50)
            .padding(.bottom, 100)
        }
    }
}

#Preview {
    BeFeedView(viewModel: BeFeedViewModel())
}
