//
//  FlickrPhoto.swift
//  PicSearch
//
//  Created by Andras Szasz on 2025. 09. 29..
//


import Foundation

struct FlickrPhoto: Decodable, Identifiable {
    let id: String
    let title: String
    let server: String
    let secret: String
    let farm: Int
    
    var imageURL: URL? {
        URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_m.jpg")
    }

    var largeImageURL: URL? {
        URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_b.jpg")
    }
    
    // The API returns invalid farm and server values sometimes
    var isValid: Bool {
        farm != 0 && server != "0"
    }
}
