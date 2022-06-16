//
//  GifCollectionViewCell.swift
//  MonkeyGiphy
//
//  Created by Adir Elmakais on 01/04/2022.
//

import UIKit
import SwiftGifOrigin


protocol MyTableViewDelegate: AnyObject {
    func shareImageButton(with data: Data )
    func saveToGalleryButton(with data: Data)
}

class GifCollectionViewCell: UICollectionViewCell {
    
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
    private var data: Data?
    private var task: URLSessionDataTask?
    weak var delegate: MyTableViewDelegate?
    static let identifier = "GifCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        task = nil
        imageView.image = nil
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
    
    @IBAction func shareImageButton(_ sender: UIButton) {
        guard let data = data else { return }
        delegate?.shareImageButton(with: data)
    }
    
    @IBAction func saveToGalleryButton(_ sender: UIButton) {
        guard let data = data else { return }
        delegate?.saveToGalleryButton(with: data)
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "GifCollectionViewCell", bundle: nil)
    }
    
}