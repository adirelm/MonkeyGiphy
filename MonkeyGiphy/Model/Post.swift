//
//  Post.swift
//  MonkeyGiphy
//
//  Created by Adir Elmakais on 01/04/2022.
//

import UIKit

struct Post: Codable {
    let data: [Result]
    let pagination: Pages
}

struct Pages: Codable {
    let total_count: Int
    let count: Int
    
}

struct Result: Codable {
    let id: String
    let images: Images
    
}

struct Images: Codable {
    let downsized: URLS
}

struct URLS: Codable {
    let url: String
}
