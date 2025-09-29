//
//  PhotoSearchView.swift
//  PicSearch
//
//  Created by Andras Szasz on 2025. 09. 29..
//


import SwiftUI

// MARK: Main view

struct PhotoSearchView: View {
    @StateObject private var viewModel = PhotoSearchViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBarView(query: $viewModel.query, onSearch: {
                    Task { await viewModel.search(reset: true) }
                })
                
                PhotoGridView(photos: viewModel.photos, loadMoreAction: { photo in
                    Task { await viewModel.loadMoreIfNeeded(current: photo) }
                })
            }
            .navigationTitle("Flickr Search")
        }
    }
}

// MARK: Subviews

struct SearchBarView: View {
    @Binding var query: String
    var onSearch: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search photos...", text: $query)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    onSearch()
                    hideKeyboard()
                }
            
            Button(action: {
                onSearch()
                hideKeyboard()
            }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Search")
        }
        .padding(.horizontal)
        .padding(.top)
    }
}

struct PhotoGridView: View {
    let photos: [FlickrPhoto]
    let loadMoreAction: (FlickrPhoto) -> Void
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                ForEach(photos, id: \.id) { photo in
                    NavigationLink(destination: PhotoDetailView(photo: photo)) {
                        PhotoCell(photo: photo)
                            .onAppear {
                                loadMoreAction(photo)
                            }
                    }
                }
            }
            .padding()
        }
    }
}

struct PhotoCell: View {
    let photo: FlickrPhoto
    
    var body: some View {
        if let imageURL = photo.imageURL {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure(_):
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 100, height: 100)
            .clipped()
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
        }
    }
}
