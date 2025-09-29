//
//  FlickrAPIConfig.swift
//  PicSearch
//
//  Created by Andras Szasz on 2025. 09. 29..
//

import Foundation

// MARK: Protocol

protocol APIConfig {
    var apiKey: String { get }
    var baseURL: String { get }
    var method: String { get }
}

// MARK: Struct - FlickrAPIConfig

// TODO: Move these to a secure place

struct FlickrAPIConfig: APIConfig {
    let apiKey = "65803e8f6e4a3982200621cad356be51"
    let baseURL = "https://www.flickr.com/services/rest/"
    let method = "flickr.photos.search"
}
