//
//  FlickrAPIService.swift
//  PicSearch
//
//  Created by Andras Szasz on 2025. 09. 29..
//


import Foundation

// MARK: Protocol

protocol APIService {
    var config: APIConfig { get }
    var session: URLSession { get }
    func searchPhotos(query: String, page: Int) async throws -> [FlickrPhoto]
}

// MARK: Class - FlickAPIService

class FlickrAPIService: APIService {
    let config: APIConfig
    let session: URLSession

    init(session: URLSession = .shared, config: APIConfig = FlickrAPIConfig()) {
        self.session = session
        self.config = config
    }

    func searchPhotos(query: String, page: Int) async throws -> [FlickrPhoto] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }

        let base = config.baseURL
        var components = URLComponents(string: base)!
        components.queryItems = [
            URLQueryItem(name: "method", value: config.method),
            URLQueryItem(name: "api_key", value: config.apiKey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1"),
            URLQueryItem(name: "text", value: trimmedQuery),
            URLQueryItem(name: "per_page", value: "20"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let result = try JSONDecoder().decode(SearchResult.self, from: data)
        return result.photosPage.photos
    }
}

// MARK: Structs

struct SearchResult: Decodable {
    let photosPage: PhotosPage
    
    enum CodingKeys: String, CodingKey {
        case photosPage = "photos"
    }
}

struct PhotosPage: Decodable {
    let page: Int
    let photos: [FlickrPhoto]
    
    enum CodingKeys: String, CodingKey {
        case page
        case photos = "photo"
    }
}
