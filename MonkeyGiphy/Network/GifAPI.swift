//
//  PostManager.swift
//  MonkeyGiphy
//
//  Created by Adir Elmakais on 04/04/2022.
//

import Foundation
import Combine

enum ApiFetchType {
    case trending
}

protocol GifAPIDelegate {
    func didUpdateData(postGifData: GiphyResponse )
    func handleScrollToTop()
}

class GifAPI {
    
    private static var gifAPI = GifAPI()
    var delegate: GifAPIDelegate?
    
    private(set) var data: [GifData] = []
    @Published private(set) var favorites: [FavoriteGif] = []
    private(set) var isLoading = false
    
    lazy var session: URLSession = {
        URLCache.shared.memoryCapacity = 512 * 1024 * 1024
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: configuration)
    }()
    
    private init() {}
    
    static func shared() -> GifAPI {
        return gifAPI
    }
    
    func modifyFavorites(with gif: FavoriteGif) {
        let indexOfElement = self.favorites.firstIndex { favoriteGif in
            favoriteGif.url == gif.url
        }
        
        if let indexOfElement = indexOfElement {
            self.favorites.remove(at: indexOfElement)
        } else {
            self.favorites.append(gif)
        }
    }

    func modifyDataSource(with data: [GifData]?) {
        if let data = data {
            self.data += data
        }
        else {
            self.data.removeAll()
        }
    }
    
    func fetchPhotosBySearch(query: String, isPagination: Bool) {
        guard !isLoading else { return }
        guard let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String else { return }
        let urlString = "https://api.giphy.com/v1/gifs/search?api_key=\(apiKey)&q=\(query)&offset=\(data.count)"
        guard let url = URL(string: urlString) else { return }
        isLoading = true
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            self?.isLoading = false
            guard let data = data, error == nil else  {
                return
            }
            do {
                let jsonResult = try JSONDecoder().decode(GiphyResponse.self, from: data)
                self?.delegate?.didUpdateData(postGifData: jsonResult)
                if !isPagination { self?.delegate?.handleScrollToTop() }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func fetchPhotos(fetchType: ApiFetchType, isPagination: Bool) {
        guard !isLoading else { return }
        guard let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String else { return }
        let urlString = getUrlByFetchType(for: fetchType, apiKey: apiKey)
        guard let url = URL(string: urlString) else { return }
        isLoading = true
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            self?.isLoading = false
            guard let data = data, error == nil else  {
                return
            }
            do {
                let jsonResult = try JSONDecoder().decode(GiphyResponse.self, from: data)
                self?.delegate?.didUpdateData(postGifData: jsonResult)
                if !isPagination { self?.delegate?.handleScrollToTop() }
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func getGifUrlByIndexPathFromDataSource(for indexPath: IndexPath) -> String? {
        guard indexPath.row <= data.count else { return nil }
        return self.data[indexPath.row].images.downsized.url
    }
    
    func getFavoriteGif(for indexPath: IndexPath) -> FavoriteGif? {
        guard indexPath.row <= favorites.count else { return nil }
        return self.favorites[indexPath.row]
    }
    
    func getRandomUrlFromDataSource(for indexPath: IndexPath) -> String? {
        guard indexPath.row <= data.count else { return nil }
        let randomIndex = Int.random(in: 0..<data.count)
        return self.data[randomIndex].images.downsized.url
    }
    
    func getGifUrlByID(for gifID: UUID) -> String? {
        guard let index = data.firstIndex(where: { gifData in
        gifData.id == gifID
        }) else { return nil }
        
        return data[index].images.downsized.url
    }
    
    private func getUrlByFetchType(for fetchType: ApiFetchType, apiKey: String) -> String {
        switch fetchType {
        case .trending:
            return "https://api.giphy.com/v1/gifs/trending?api_key=\(apiKey)&offset=\(data.count)"
        }
    }
}
