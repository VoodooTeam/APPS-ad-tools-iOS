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
    
    @Published var feedItems: [FeedItem] = []
    
    private let prefilledItems = getPrefilledItems()
    private var mediaViewModels: [Media.ID: MediaViewModel] = [:]

    
    init() {
        handleLoad()
        
        AdCoordinator.shared.firstAdLoadedCallback = { [weak self] in
            guard let self = self else { return }
            guard AdCoordinator.shared.shouldDisplayFooterAd(forDataSize: self.feedItems.count) else { return }
            self.handleLoad()
        }
    }
    
    // MARK: - View interactions
    
    func cellViewModel(for media: Media) -> MediaViewModel {
        let viewModel = MediaViewModel(with: MediaCoordinatorInput(media: .loaded(media: media)))
        mediaViewModels[media.id] = viewModel
        return viewModel
    }
    
    // MARK: - Private
    
    private func handleLoad() {
        feedItems = prefilledItems
        
        AdCoordinator.shared.allAdIndexes.forEach { index in
            guard index < feedItems.count else { return }
            self.feedItems.insert(FeedItem(id: "ad-\(index)", content: FeedItemContent.adIndex(index)), at: index)
        }
    }
    
    private static func getPrefilledItems() -> [FeedItem] {
        memeDatasetsFilenames.enumerated().map { index, assetName in
            let id = UUID().uuidString
            return FeedItem(id: id, content: .media(Media(
                id: id,
                createdAt: Date(),
                updatedAt: Date(),
                content: MediaContent(source: .asset(assetName),
                thumbnail: nil,
                size: MediaContent.Size(height: 0, width: 0)),
                author: .voodoo,
                state: .synced(at: Date()),
                isUnseen: false
            )))
        }
    }
    
    func didDisplay(item: FeedItem) {
        Task {
            guard let index = feedItems.firstIndex(where: { $0.id == item.id }) else { return }
            let adIndex = min(index + AdConfig.fetchOffset, feedItems.count)
            let surroundingIds = [feedItems[safe: adIndex-1], feedItems[safe: adIndex+1]].compactMap { $0?.id }
            guard AdCoordinator.shared.isAdAvailable(for: adIndex, surroundingIds: surroundingIds) else { return }
            await MainActor.run {self.handleLoad()}
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
