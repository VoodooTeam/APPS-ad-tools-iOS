//
//  BeMediaView.swift
//  Drop
//
//  Created by Michel-André Chirita on 22/05/2024.
//

import Foundation
import SwiftUI
import Kingfisher
//import Core

struct BeMediaView: View {
        
    @StateObject var viewModel: MediaViewModel

    var body: some View {
        VStack(spacing: 7) {
            header
            ZStack(alignment: .bottomTrailing) {
                backgroundImage
                if let id = viewModel.media?.id, let intId = Int(id), intId < 0 {
                    EmptyView()
                } else {
                    commentsButton
                }
            }
            footer
        }
        .onAppear {
            viewModel.viewDidAppear()
        }
        .onDisappear() {
            viewModel.viewDidDisappear()
        }

    }
    
    @ViewBuilder
    private var header: some View {
        HStack(spacing: 10) {
            authorAvatar
            
            if let media = viewModel.media {
                VStack(alignment: .leading, spacing: 0) {
                    Text(media.author.displayName)
                        .foregroundStyle(.white)
                        .font(.system(size: 14, weight: .semibold))
                    Text(format(date: media.createdAt))
                        .foregroundStyle(.gray)
                        .font(.system(size: 12, weight: .regular))
                }
            }
            Spacer()
        }
        .padding(.horizontal, 15)
    }
    
    private func format(date: Date) -> String {
        let relativeDateFormatter = DateFormatter()
        relativeDateFormatter.timeStyle = .short
        relativeDateFormatter.dateStyle = .medium
        relativeDateFormatter.locale = Locale(identifier: "us_US")
        relativeDateFormatter.doesRelativeDateFormatting = true
        return relativeDateFormatter.string(from: date)
    }
    
    @ViewBuilder
    private var authorAvatar: some View {
        if let photo = viewModel.media?.author.photo {
            UserPhotoView(photoSource: photo)
                .frame(width: 35, height: 35)
        }
    }
    
    @ViewBuilder
    private var commentsButton: some View {
        Image(systemName: "bubble.left.fill")
            .foregroundStyle(.white)
            .font(.system(size: 21, weight: .bold))
            .shadow(color: .black.opacity(0.5), radius: 2)
            .padding()
    }
    
    @ViewBuilder
    private var backgroundImage: some View {
        switch viewModel.backgroundMediaSource {
        case .url(let photoUrl):
            RoundedRectangle(cornerRadius: 20)
                .fill(.clear)
                .frame(height: 520)
                .containerRelativeFrame(.horizontal)
                .background {
                    KFImage(photoUrl)
                        .placeholder { PlaceholderView() }
                        .retry(maxCount: 3, interval: .seconds(1))
                        .resizable()
                        .scaledToFit()
                }
                .background { Color(white: 14/255) }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .allowsHitTesting(false)

        case .data(let data):
            Image(uiImage: UIImage(data: data) ?? UIImage(named: "image_1")!)
                .resizable()
                .scaledToFill()
                .frame(height: 520)
                .containerRelativeFrame(.horizontal)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .allowsHitTesting(false)

        case .none:
            Image(uiImage: UIImage(named: "image_1")!)
                .resizable()
                .scaledToFill()
                .frame(height: 520)
                .containerRelativeFrame(.horizontal)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .allowsHitTesting(false)

        case .asset(let string):
            RoundedRectangle(cornerRadius: 20)
                .fill(.clear)
                .frame(height: 520)
                .containerRelativeFrame(.horizontal)
                .background {
                    Image(string)
                        .resizable()
                        .scaledToFit()
                }
                .background { Color(white: 14/255) }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .allowsHitTesting(false)
        }
    }
    
    @ViewBuilder
    private var footer: some View {
        EmptyView()
    }
}

//#Preview {
//    BeMediaView()
//}
