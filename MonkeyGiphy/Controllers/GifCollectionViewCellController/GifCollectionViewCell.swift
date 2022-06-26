//
//  GifCollectionViewCell.swift
//  MonkeyGiphy
//
//  Created by Adir Elmakais on 01/04/2022.
//

import UIKit
import SwiftGifOrigin

class GifCollectionViewCell: UICollectionViewCell {
    private var data: Data?
    private var task: URLSessionDataTask?
    static let identifier = "GifCollectionViewCell"
    @IBOutlet var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 8.0
        }
    }
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet {
            activityIndicator.hidesWhenStopped = true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        task = nil
        imageView.image = nil
    }
    
    func getDataOfCell() -> Data? {
        guard let data = data else { return nil }
        return data
    }
    
    func configure(with urlString: String, session: URLSession) {
        self.activityIndicator.startAnimating()
        guard let url = URL(string: urlString) else { return }
        let task = session.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                let gif = UIImage.gif(data: data)
                self?.imageView.image = gif
                self?.data = data
                self?.activityIndicator.stopAnimating()
            }
        }
        task.resume()
        self.task = task
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "GifCollectionViewCell", bundle: nil)
    }
    
}
