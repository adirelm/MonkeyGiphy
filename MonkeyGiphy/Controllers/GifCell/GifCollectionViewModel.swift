//
//  GifCollectionViewModel.swift
//  MonkeyGiphy
//
//  Created by Adir Elmakais on 02/07/2022.
//

import Foundation

class GifCollectionViewModel {
    
    var data: Data?
    var task: URLSessionDataTask?
    var gifURL: String?
    
    
    func configure(with urlString: String, session: URLSession) {
        guard let url = URL(string: urlString) else { return }
        let task = session.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self?.data = data
                self?.gifURL = urlString
            }
        }
        task.resume()
        self.task = task
    }
}
