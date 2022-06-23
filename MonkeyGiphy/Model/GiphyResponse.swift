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

struct GifData: Codable, Identifiable {
    let id = UUID()
    let images: Images
}

struct Images: Codable {
    let downsized: URLS
}

struct URLS: Codable {
    let url: String
}
