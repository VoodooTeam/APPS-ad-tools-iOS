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
                Button("AppLovin Mediation Debugger") {
                    AdInitializer.appLoSdk.showMediationDebugger()
                }
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
            }
            .padding(.top, 50)
            .padding(.bottom, 100)
        }
    }
}

#Preview {
    BeFeedView(viewModel: BeFeedViewModel())
}
