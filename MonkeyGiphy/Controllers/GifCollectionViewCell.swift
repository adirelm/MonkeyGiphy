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
    
    weak var delegate: MyTableViewDelegate?
    
    @IBOutlet var imageView: UIImageView!
    var data: Data?
    
    static let identifier = "GifCollectionViewCell"
    var task: URLSessionDataTask?

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
        guard let url = URL(string: urlString) else {
            return
        }
    
        let task = session.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                let gif = UIImage.gif(data: data)
                self?.imageView.image = gif
                self?.data = data
            }
        }
        task.resume()
        
        self.task = task
        
        
        
    }
    
    
    
    @IBAction func shareImageButton(_ sender: UIButton) {
        delegate?.shareImageButton(with: self.data!)
    }
    
    
    @IBAction func saveToGalleryButton(_ sender: UIButton) {
        delegate?.saveToGalleryButton(with: self.data!)
    }
    

    static func nib() -> UINib {
        return UINib(nibName: "GifCollectionViewCell", bundle: nil)
    }
    


}
