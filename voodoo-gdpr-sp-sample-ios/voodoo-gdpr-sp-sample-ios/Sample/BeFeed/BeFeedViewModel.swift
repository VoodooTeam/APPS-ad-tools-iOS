//
//  BeFeedViewModel.swift
//  Drop
//
//  Created by Michel-André Chirita on 22/05/2024.
//

import Foundation
import Combine
import SwiftUI
import Kingfisher

@MainActor
final class BeFeedViewModel: ObservableObject {
    
    struct FeedItem: Identifiable {
        let id: String
        let content: FeedItemContent
        var isContent: Bool {
            switch content {
            case .media: true
            case .adIndex: false
            }
        }
    }
    
    enum FeedItemContent {
        case media(Media)
        case adIndex(Int)
    }
    
    @Published var verticalScrollPosition: Int?
    @Published var mediaScrollPosition: String?
    @Published var feedItems: [FeedItem] = []
    private var mediaViewModels: [Media.ID: MediaViewModel] = [:]
    
    init() {
        handleLoad()
    }
    
    // MARK: - View interactions
    
    func cellViewModel(for media: Media) -> MediaViewModel {
        let viewModel = MediaViewModel(with: MediaCoordinatorInput(media: .loaded(media: media)))
        mediaViewModels[media.id] = viewModel
        return viewModel
    }
    
    // MARK: - Private
    
    private func handleLoad() {
        let prefillMedias = getPrefillMedias()
        feedItems = prefillMedias.map { FeedItem(id: $0.id, content: FeedItemContent.media($0)) }
        
        AdCoordinator.shared.allAdIndexes.forEach { index in
            guard index < feedItems.count else { return }
            self.feedItems.insert(FeedItem(id: "ad-\(index)", content: FeedItemContent.adIndex(index)), at: index)
        }
    }
    
    private func getPrefillMedias() -> [Media] {
        memeDatasetsFilenames.enumerated().map { index, assetName in
            Media(
                id: "-\(index + 1)",
                createdAt: Date(), 
                updatedAt: Date(),
                content: MediaContent(source: .asset(assetName),
                thumbnail: nil,
                size: MediaContent.Size(height: 0, width: 0)),
                author: .voodoo,
                state: .synced(at: Date()),
                isUnseen: false
            )
        }
    }
    
    // MARK: - Limitless
    
    private let adCheckOffset = 1
    private var lastDisplayedId: Int = 0

    func didDisplay(item: FeedItem) {
        Task {
            guard let index = feedItems.firstIndex(where: { $0.id == item.id }), index > lastDisplayedId else { return }
            lastDisplayedId = index
            let adIndex = min(index + AdConfig.fetchOffset, feedItems.count)
            let surroundingIds = [feedItems[safe: index], feedItems[safe: index+1]].compactMap { $0?.id }
            guard AdCoordinator.shared.isAdAvailable(for: adIndex, surroundingIds: surroundingIds) else { return }
            await MainActor.run {
                self.handleLoad()
            }
        }
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        guard index >= startIndex && index < endIndex else {
            return nil
        }
        return self[index]
    }
}
