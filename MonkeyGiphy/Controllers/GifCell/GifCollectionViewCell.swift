//
//  GifCollectionViewCell.swift
//  MonkeyGiphy
//
//  Created by Adir Elmakais on 01/04/2022.
//

import UIKit
import SwiftGifOrigin

class GifCollectionViewCell: UICollectionViewCell {
    private let viewModel = GifCollectionViewModel()
    var data: Data?
    var task: URLSessionDataTask?
    var gifURL: String?
    static let identifier = "GifCollectionViewCell"
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setImageView()
        setActivittyIndicator()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel.task?.cancel()
        viewModel.task = nil
        imageView.image = nil
//        task?.cancel()
//        task = nil
    }
    
    private func setImageView() {
        self.imageView.layer.cornerRadius = 8.0
    }
    
    private func setActivittyIndicator() {
        self.activityIndicator.hidesWhenStopped = true
    }
    
    func getDataOfCell() -> Data? {
        guard let data = viewModel.data else { return nil }
        return data
        
//        guard let data = data else { return nil }
//        return data
    }
    
    func getGifURLOfCell() -> String? {
        guard let url = viewModel.gifURL else { return nil }
        return url
        
//        guard let url = gifURL else { return nil }
//        return url
    }
    
//    func configure(with urlString: String, session: URLSession) {
//        self.activityIndicator.startAnimating()
//        guard let url = URL(string: urlString) else { return }
//        let task = session.dataTask(with: url) { [weak self] data, _, error in
//            guard let data = data, error == nil else { return }
//            DispatchQueue.main.async {
//                let gif = UIImage.gif(data: data)
//                self?.imageView.image = gif
//                self?.data = data
//                self?.gifURL = urlString
//                self?.activityIndicator.stopAnimating()
//            }
//        }
//        task.resume()
//        self.task = task
//    }
    
    func configure(with urlString: String, session: URLSession) {
        self.activityIndicator.startAnimating()
        viewModel.configure(with: urlString, session: session)
        guard let data = self.viewModel.data else { return }
        DispatchQueue.main.async { [weak self] in
            let gifImage = UIImage.gif(data: data)
            self?.imageView.image = gifImage
            self?.activityIndicator.stopAnimating()
        }
    }
    
    
    
    static func nib() -> UINib {
        return UINib(nibName: "GifCollectionViewCell", bundle: nil)
    }
    
}
