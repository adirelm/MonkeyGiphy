//
//  Post.swift
//  MonkeyGiphy
//
//  Created by Adir Elmakais on 01/04/2022.
//

import UIKit

struct GiphyResponse: Codable {
    let data: [GifData]
    let pagination: PaginationData
}

struct PaginationData: Codable {
    let total_count: Int
    let count: Int
    let offset: Int
}

struct GifData: Codable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: GifData, rhs: GifData) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String
    let images: Images
}

struct Images: Codable {
    let downsized: URLS
}

struct URLS: Codable {
    let url: String
}
