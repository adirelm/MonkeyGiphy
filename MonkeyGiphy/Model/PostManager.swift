//
//  PostManager.swift
//  MonkeyGiphy
//
//  Created by Adir Elmakais on 04/04/2022.
//

import Foundation

protocol PostManagerDelegate {
    func didUpdateData(postManager: PostManager?, postGifData: Post )
}

class PostManager {
    var URLString: String?
    
    private(set) var data: [Result] = []
    private(set) var isLoading = false
    
    lazy var session: URLSession = {
        URLCache.shared.memoryCapacity = 512 * 1024 * 1024
        let configuration = URLSessionConfiguration.default
        
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        return URLSession(configuration: configuration)
    }()
    
    var delegate: PostManagerDelegate?
    
    func modifyDataSource(with data: [Result]?) {
        if let data = data {
            self.data += data
        }
        else { self.data.removeAll() }
    }
    
    func fetchPhotos(query: String) {
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
                let jsonResult = try JSONDecoder().decode(Post.self, from: data)
                self?.delegate?.didUpdateData(postManager: self, postGifData: jsonResult)
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
    
}
