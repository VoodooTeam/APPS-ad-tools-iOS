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
                HStack {
                    Button("AppLo Debug") {
                        ALSdk.shared().showMediationDebugger()
                    }
                    Spacer()
                    Button("Privacy Settings") {
                        PrivacyManager.shared.loadAndDisplayConsentUI()
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
                            .fixedSize(horizontal: false, vertical: true)
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

struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.backgroundColor = .clear
            view.superview?.backgroundColor = .clear
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
