//
//  UserPhotoView.swift
//  Drop
//
//  Created by Michel-André Chirita on 03/02/2024.
//

import SwiftUI
import Kingfisher

struct UserPhotoView: View {
    
    var photoSource: PhotoSource
    var hexColor: String? = nil
    var borderWidth: Double = 0.0

    var body: some View {
        Circle()
            .foregroundStyle(hexColor != nil ? .red : .clear)
            .overlay {
                switch photoSource {
                case .url(let photoUrl):
                    KFImage(photoUrl)
                        .placeholder { PlaceholderView() }
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .padding(borderWidth)
                    
                case .data(let data):
                    Image(uiImage: UIImage(data: data) ?? UIImage(named: "image_1")!)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .padding(borderWidth)
                    
                case .none:
                    Image(uiImage: UIImage(named: "image_1")!)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .padding(1.0)
                        .background {
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1.0)
                        }
                        .padding(1.0)

                case .asset(let string):
                    Image(string)
                        .resizable()
                        .scaledToFill()
                        .clipShape(Circle())
                        .padding(borderWidth)
                }
            }
    }
}

#Preview {
    UserPhotoView(photoSource: .asset("MockUserPicture1"), hexColor: "eb4034")
}
