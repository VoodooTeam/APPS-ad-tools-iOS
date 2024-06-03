//
//  MediaViewModel.swift
//  Drop
//
//  Created by Michel-André Chirita on 01/02/2024.
//

import Foundation
import Combine
import SwiftUI
//import Core

@MainActor
final class MediaViewModel: ObservableObject {

    @Published var newComment: String = ""
    @Published var backgroundMediaSource: PhotoSource
    @Published var userPhotoSource: PhotoSource? = PhotoSource.none
    @Published var mediaState: Media.State
    @Published var hideComments: Bool
    @Published var isEditing: Bool = false
    @Published var media: Media?
    private let mediaId: Media.ID
    private var cancellables = Set<AnyCancellable>()
//    var mediaInfoViewModel: MediaInfosViewModel?
    var mediaIsVisible: Bool = false

    init(with input: MediaCoordinatorInput) {
        switch input.media {
        case .loaded(let media):
//            self.mediaInfoViewModel = MediaInfosViewModel(with: media)
            self.media = media
            self.mediaId = media.id
            self.mediaState = media.state
            self.backgroundMediaSource = media.content.source
            self.hideComments = false
//            self.commentsViewModel = CommentsFeedViewModel(media: media)
//            commentsViewModel?.scrollViewDelegate = self

        case .loading(let mediaId, let source):
            self.mediaId = mediaId
            self.backgroundMediaSource = source
            self.mediaState = .fetching
            self.hideComments = false //true
        }

//        Task {
////            userPhotoSource = .asset("")
////            self.userPhotoSource = await appState.dataStore.currentUser?.photo ?? PhotoSource.none
//            
////            await appState.dataStore.$medias
////                .compactMap { [weak self] (allMedias: [Media]) -> Media? in
////                    guard let self else { return nil }
////                    return allMedias.first { media in media.id == self.mediaId }
////                }
////                .receive(on: DispatchQueue.main)
////                .sink { [weak self] newMedia in
////                    guard let self else { return }
////                    self.media = media
////                    self.update(with: media)
////                }
////                .store(in: &cancellables)
//        }
    }
    
    private func update(with media: Media) {
////        self.mediaInfoViewModel = MediaInfosViewModel(with: media)
//        self.media = media
//        self.mediaState = media.state
//        self.backgroundMediaSource = media.content.source
//        Task {
//            self.userPhotoSource = await appState.dataStore.currentUser?.photo ?? PhotoSource.none
//        }
//        
//        if commentsViewModel == nil {
//            self.commentsViewModel = CommentsFeedViewModel(media: media)
//            commentsViewModel?.scrollViewDelegate = self
//            self.hideComments = false // media.isUnseen
//        }
//        
////        if mediaIsVisible, (media.isUnseen || media.unseenComments > 0) {
////            Task.detached { [mediaWorker] in
////                try await mediaWorker.mediaSeen(mediaId: media.id)
////            }
////        }
    }

    // MARK: - Interactions
    
    func viewDidAppear() {
        mediaIsVisible = true
        
//        guard let media else { return }
//        if media.isUnseen || media.unseenComments > 0 {
//            Task.detached { [mediaWorker] in
//                try await mediaWorker.mediaSeen(mediaId: media.id)
//            }
//        }
    }
    
    func viewDidDisappear() {
        mediaIsVisible = false
    }
    
//    func send(newTextComment: String) {
//        Task.detached { [mediaId, commentWorker, self, analyticsService] in
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                self.commentsViewModel?.scrollViewController?.scrollToBottom(force: true, animated: true) // capture des 2 VMs ici
//            }
//            let request = PostCommentRequest(mediaId: mediaId, content: Comment.Content.text(newTextComment))
//            try await commentWorker.sendComment(request: request)
//            analyticsService.send(event: MediaAnalytics.sendNewComment)
//        }
//    }
//    
//    func send(newGifComment: String) {
//        Task.detached { [mediaId, commentWorker, analyticsService] in
//            let request = PostCommentRequest(mediaId: mediaId, content: Comment.Content.gif(id: newGifComment))
//            try await commentWorker.sendComment(request: request)
//            analyticsService.send(event: MediaAnalytics.sendNewComment)
//        }
//    }
}

//
//extension MediaViewModel: ScrollViewDelegate {
////    func longPress(active: Bool) {
////        self.hideComments = active
////    }
//    
//    func didTap() {
//        self.isEditing = false
//    }
//}


struct MediaCoordinatorInput {
    let media: MediaTarget
//    let newGroupRecipients: Recipients? // à choper directement du media ?

    enum MediaTarget {
        case loaded(media: Media)
        case loading(mediaId: Media.ID, source: PhotoSource)
        
        var mediaId: Media.ID {
            switch self {
            case .loaded(let media): media.id
            case .loading(let mediaId, _): mediaId
            }
        }
    }
}
