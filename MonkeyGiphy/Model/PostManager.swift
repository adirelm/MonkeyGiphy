//
//  PostManager.swift
//  MonkeyGiphy
//
//  Created by Adir Elmakais on 04/04/2022.
//

import Foundation

protocol PostManagerDelegate {
    func didUpdateData(postManager: PostManager, postGifData: Post )
}

struct PostManager {
    var URLString: String?
    
    lazy var session: URLSession = {
        URLCache.shared.memoryCapacity = 512 * 1024 * 1024
        let configuration = URLSessionConfiguration.default
        
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        
        return URLSession(configuration: configuration)
    }()
    
    var delegate: PostManagerDelegate?
    
    
    func fetchPhotos(query: String) {
                guard let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String else {
                    return
                }
        let urlString = "https://api.giphy.com/v1/gifs/search?api_key=\(apiKey)&q=\(query)"
        guard let url = URL(string: urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) {  data, _, error in
            guard let data = data, error == nil else  {
                return
            }
            
            do {
                let jsonResult = try JSONDecoder().decode(Post.self, from: data)
                self.delegate?.didUpdateData(postManager: self, postGifData: jsonResult)
                
            }
            catch {
                print(error)
            }
        }
        task.resume()
    }
    
}
