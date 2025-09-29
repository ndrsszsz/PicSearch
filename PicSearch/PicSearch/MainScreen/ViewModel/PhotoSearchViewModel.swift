//
//  PhotoSearchViewModel.swift
//  PicSearch
//
//  Created by Andras Szasz on 2025. 09. 29..
//


import SwiftUI

@MainActor
class PhotoSearchViewModel: ObservableObject {
    
    // MARK: Outputs

    @Published var photos: [FlickrPhoto] = []
    @Published var query: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var noResults = false

    // MARK: Privates

    private var page = 1
    private var canLoadMore = true
    private let service: APIService

    // MARK: Init

    init(service: APIService = FlickrAPIService(), autoLoad: Bool = true) {
        self.service = service
        query = UserDefaults.standard.string(forKey: "lastSearch") ?? "dog"
        if autoLoad {
            Task { await search(reset: true) }
        }
    }

    // MARK: Methods

    func search(reset: Bool = false) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        noResults = false

        if reset {
            page = 1
            canLoadMore = true
            photos = []
            if UserDefaults.standard.string(forKey: "lastSearch") != query {
                UserDefaults.standard.setValue(query, forKey: "lastSearch")
            }
        }

        do {
            let existingPhotoIds = Set(photos.map(\.id))
            let newPhotos = try await service.searchPhotos(query: query, page: page)
            let validPhotos = newPhotos.filter { $0.isValid && !existingPhotoIds.contains($0.id) }

            if reset && validPhotos.isEmpty {
                noResults = true
            }

            photos += validPhotos
            if validPhotos.count < 20 {
                canLoadMore = false
            } else {
                page += 1
            }
        } catch {
            errorMessage = error.localizedDescription
            print("API error: \(error)")
        }

        isLoading = false
    }

    func loadMoreIfNeeded(current photo: FlickrPhoto) async {
        guard canLoadMore, !isLoading else { return }
        let thresholdIndex = max(0, photos.count - 5)
        if let index = photos.firstIndex(where: { $0.id == photo.id }), index >= thresholdIndex {
            await search()
        }
    }
}
