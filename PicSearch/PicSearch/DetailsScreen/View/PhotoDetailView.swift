//
//  PhotoDetailView.swift
//  PicSearch
//
//  Created by Andras Szasz on 2025. 09. 29..
//


import SwiftUI

struct PhotoDetailView: View {
    let photo: FlickrPhoto

    var body: some View {
        VStack {
            if let url = photo.largeImageURL {
                ZoomablePhotoView(url: url)
                    .edgesIgnoringSafeArea(.horizontal)
            } else {
                EmptyPhotoView()
                    .frame(maxWidth: .infinity, maxHeight: 300)
            }

            Text(photo.title)
                .font(.headline)
                .padding()

            Spacer()
        }
        .navigationTitle("Photo Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: Subviews

struct ZoomablePhotoView: View {
    let url: URL

    var body: some View {
        ZoomableImageView {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure(_):
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
        }
    }
}

struct EmptyPhotoView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.yellow)

            Text("Sorry. This image is not available.")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}
