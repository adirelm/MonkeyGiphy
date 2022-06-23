//
//  FullScreenGifViewController.swift
//  MonkeyGiphy
//
//  Created by Adir Elmakais on 31/05/2022.
//

import UIKit
import Photos

class FullScreenGifViewController: UIViewController {

    @IBOutlet weak var gifImageView: UIImageView!
    private let image: UIImage
    private let data: Data
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGifImageView(image: image)
    }
    
    init?(coder: NSCoder, image: UIImage, data: Data) {
        self.image = image
        self.data = data
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //MARK: - Private Methods
    @IBAction private func saveToGalleryButton(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Save gif to Camera Roll?", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Save!", style: .destructive, handler: {_ in
            let refreshAlert = UIAlertController(title: "Yay!", message: "Gif saved to Camera Roll!", preferredStyle: UIAlertController.Style.alert)
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            PHPhotoLibrary.shared().performChanges({ [weak self] in
                guard let data = self?.data else { return }
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .photo, data: data, options: nil)
            }) { (success, error) in
                if error == nil {
                    return
                }
            }
            self.present(refreshAlert, animated: true, completion: nil)
        }))
        present(actionSheet, animated: true)
    }
    
    @IBAction private func shareImageButton(_ sender: UIButton) {
        let firstActivityItem: Array = [data]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: firstActivityItem, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func configureGifImageView(image: UIImage) {
        self.gifImageView.image = image
    }
}
