//
//  FullScreenGifViewController.swift
//  MonkeyGiphy
//
//  Created by Adir Elmakais on 31/05/2022.
//

import UIKit

class FullScreenGifViewController: UIViewController {

    @IBOutlet weak var gifImageView: UIImageView!
    private var image: UIImage
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGifImageView(image: image)
    }
    
    init?(coder: NSCoder, image: UIImage) {
        self.image = image
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func configureGifImageView(image: UIImage) {
        self.gifImageView.image = image
    }
}
